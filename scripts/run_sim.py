from __future__ import annotations

import argparse
import os
import shutil
import subprocess
from pathlib import Path


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


def collect_rtl_sources(repo_root: Path, primary_rtl: Path) -> list[Path]:
    rtl_dir = repo_root / "rtl"
    rtl_sources = sorted(path for path in rtl_dir.glob("*.v") if path != primary_rtl)
    return [primary_rtl, *rtl_sources]


def main() -> None:
    parser = argparse.ArgumentParser(description="Compile and run a Verilog simulation.")
    parser.add_argument("target", nargs="?", default="traffic_light_controller")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    rtl_path = repo_root / "rtl" / f"{args.target}.v"
    tb_path = repo_root / "tb" / f"tb_{args.target}.v"
    sim_dir = repo_root / "sim"
    waves_dir = repo_root / "waves"

    if not rtl_path.exists():
        raise SystemExit(f"RTL file not found: {rtl_path}")
    if not tb_path.exists():
        raise SystemExit(f"Testbench file not found: {tb_path}")

    sim_dir.mkdir(parents=True, exist_ok=True)
    waves_dir.mkdir(parents=True, exist_ok=True)

    compiled_path = sim_dir / f"{args.target}.vvp"
    compile_log = sim_dir / f"{args.target}_compile.log"
    run_log = sim_dir / f"{args.target}_run.log"
    waveform_path = waves_dir / f"{args.target}.vcd"

    compile_command = [
        "iverilog",
        "-g2012",
        "-o",
        str(compiled_path),
        f'-DVCD_FILE=\"{waveform_path.as_posix()}\"',
        *(str(path) for path in collect_rtl_sources(repo_root, rtl_path)),
        str(tb_path),
    ]
    run_command(compile_command, repo_root, compile_log)
    run_command(["vvp", str(compiled_path)], repo_root, run_log)

    print(f"Simulation completed for {args.target}")
    print(f"Compiled output: {compiled_path}")
    print(f"Waveform: {waveform_path}")
    print(f"Run log: {run_log}")


if __name__ == "__main__":
    main()
