from __future__ import annotations

import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Analyze placeholder power data.")
    parser.add_argument("report", nargs="?", default="reports/power.txt")
    parser.parse_args()

    # TODO: Compare baseline and clock-gated designs.
    # TODO: Estimate switching activity and simple energy trends.
    # TODO: Summarize low-power observations for beginners.
    _ = Path


if __name__ == "__main__":
    main()
