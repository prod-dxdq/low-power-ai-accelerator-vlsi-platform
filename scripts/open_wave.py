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


def parse_vcd_signals(vcd_path: Path) -> tuple[str, list[str]]:
    scope_stack: list[str] = []
    top_scope = ""
    top_signals: list[str] = []
    child_signals: list[str] = []
    top_leaf_names: set[str] = set()

    with vcd_path.open("r", encoding="utf-8", errors="replace") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if line == "$enddefinitions $end":
                break

            if line.startswith("$scope"):
                parts = line.split()
                if len(parts) >= 4:
                    scope_name = parts[2]
                    scope_stack.append(scope_name)
                    if not top_scope:
                        top_scope = scope_name
                continue

            if line.startswith("$upscope"):
                if scope_stack:
                    scope_stack.pop()
                continue

            if not line.startswith("$var"):
                continue

            parts = line.split()
            if len(parts) < 6 or not scope_stack:
                continue

            var_type = parts[1]
            if var_type == "parameter":
                continue

            signal_name = " ".join(parts[4:-1]).replace(" [", "[")
            full_name = ".".join(scope_stack + [signal_name])

            if len(scope_stack) == 1:
                top_signals.append(full_name)
                top_leaf_names.add(signal_name)
                continue

            if len(scope_stack) == 2 and signal_name not in top_leaf_names:
                child_signals.append(full_name)

    if not top_scope:
        raise SystemExit(f"No module scopes found in {vcd_path}")

    return top_scope, top_signals + child_signals


def write_savefile(save_path: Path, dump_path: Path, signals: list[str]) -> None:
    dump_info = dump_path.stat()
    lines = [
        "[*]",
        "[*] GTKWave Analyzer save file",
        "[*]",
        "[dumpfile]",
        f'"{dump_path}"',
        f'[dumpfile_mtime] "{dump_info.st_mtime_ns}"',
        f"[dumpfile_size] {dump_info.st_size}",
        "[savefile]",
        f'"{save_path}"',
        "[timestart] 0",
        "[size] 1100 700",
        "[pos] -1 -1",
        "*-3.000000 0",
        "[sst_width] 220",
        "[signals_width] 220",
        "[sst_expanded] 1",
        "[sst_vpaned_height] 180",
        "@28",
    ]
    lines.extend(signals)
    save_path.write_text("\n".join(lines) + "\n", encoding="ascii")


def main() -> None:
    parser = argparse.ArgumentParser(description="Open a GTKWave session with auto-generated signals for a target.")
    parser.add_argument("target", nargs="?", default="traffic_light_controller")
    parser.add_argument("--no-open", action="store_true", help="Generate the savefile but do not launch GTKWave.")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    dump_path = repo_root / "waves" / f"{args.target}.vcd"
    save_path = repo_root / "waves" / f"{args.target}.gtkw"
    rc_path = repo_root / "scripts" / "wavefit.gtkwaverc"

    if not dump_path.exists():
        raise SystemExit(f"Waveform file not found: {dump_path}")

    _, signals = parse_vcd_signals(dump_path)
    if not signals:
        raise SystemExit(f"No displayable signals found in {dump_path}")

    write_savefile(save_path, dump_path, signals)

    print(f"Generated savefile: {save_path}")
    print("Signals loaded:")
    for signal in signals:
        print(f"  {signal}")

    if args.no_open:
        return

    gtkwave_path = shutil.which("gtkwave")
    if not gtkwave_path:
        raise SystemExit("gtkwave was not found on PATH")

    subprocess.Popen(
        [gtkwave_path, "-r", str(rc_path), str(dump_path), str(save_path)],
        cwd=repo_root,
        env=build_tool_env("gtkwave"),
    )


if __name__ == "__main__":
    main()