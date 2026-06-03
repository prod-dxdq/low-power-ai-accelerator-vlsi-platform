from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
from pathlib import Path


def apply_light_svg_theme(svg_path: Path) -> None:
    svg_text = svg_path.read_text(encoding="utf-8")
    if "style=\"background:#ffffff\"" not in svg_text:
        svg_text = re.sub(r"<svg\b", '<svg style="background:#ffffff"', svg_text, count=1)

    if "<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\"/>" not in svg_text:
        svg_text = re.sub(
            r"(<svg[^>]*>)",
            r'\1\n  <rect width="100%" height="100%" fill="#ffffff"/>',
            svg_text,
            count=1,
        )

    svg_path.write_text(svg_text, encoding="utf-8")


def build_tool_env(tool_name: str) -> dict[str, str]:
    env = os.environ.copy()
    tool_path = shutil.which(tool_name)
    if not tool_path:
        return env

    tool_dir = Path(tool_path).resolve().parent
    suite_root = tool_dir.parent
    extra_paths = [tool_dir, suite_root / "lib", suite_root / "lib" / "ivl"]
    env["PATH"] = os.pathsep.join(str(path) for path in extra_paths) + os.pathsep + env.get("PATH", "")
    return env


def run_command(command: list[str], cwd: Path, log_path: Path) -> None:
    result = subprocess.run(
        command,
        cwd=cwd,
        text=True,
        capture_output=True,
        check=False,
        env=build_tool_env(command[0]),
    )
    output = (result.stdout or "") + (result.stderr or "")
    log_path.write_text(output, encoding="utf-8")
    if result.returncode != 0:
        raise SystemExit(
            f"Command failed with exit code {result.returncode}: {' '.join(command)}\n"
            f"See {log_path} for details."
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate an RTL schematic with Yosys and netlistsvg.")
    parser.add_argument("target", nargs="?", default="mac_unit")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    rtl_path = repo_root / "rtl" / f"{args.target}.v"
    reports_dir = repo_root / "reports"
    schematics_dir = repo_root / "schematics"

    if not rtl_path.exists():
        raise SystemExit(f"RTL file not found: {rtl_path}")

    reports_dir.mkdir(parents=True, exist_ok=True)
    schematics_dir.mkdir(parents=True, exist_ok=True)

    json_path = schematics_dir / f"{args.target}.json"
    svg_path = schematics_dir / f"{args.target}.svg"
    yosys_log = reports_dir / f"{args.target}_yosys.log"
    netlistsvg_log = reports_dir / f"{args.target}_netlistsvg.log"

    yosys_script = (
        f"read_verilog {rtl_path.as_posix()}; "
        f"prep -top {args.target}; "
        f"write_json {json_path.as_posix()}"
    )
    run_command(["yosys", "-p", yosys_script], repo_root, yosys_log)
    run_command(
        ["netlistsvg.cmd", str(json_path), "-o", str(svg_path)],
        repo_root,
        netlistsvg_log,
    )
    apply_light_svg_theme(svg_path)

    print(f"Schematic generated for {args.target}")
    print(f"Netlist: {json_path}")
    print(f"SVG: {svg_path}")
    print(f"Yosys log: {yosys_log}")


if __name__ == "__main__":
    main()
