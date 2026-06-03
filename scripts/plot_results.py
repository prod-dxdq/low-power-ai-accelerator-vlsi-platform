from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt


def main() -> None:
    parser = argparse.ArgumentParser(description="Plot placeholder learning results.")
    parser.add_argument("input", nargs="?", default="reports/summary.json")
    parser.parse_args()

    # TODO: Plot area, timing, and power comparisons.
    # TODO: Save plots into the plots/ directory.
    # TODO: Keep charts simple and readable for step-by-step learning.
    _ = plt
    _ = Path


if __name__ == "__main__":
    main()
