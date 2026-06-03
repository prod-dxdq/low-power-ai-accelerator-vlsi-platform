from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate placeholder test vectors.")
    parser.add_argument("--count", type=int, default=8)
    parser.parse_args()

    # TODO: Create deterministic vectors for ALU, MAC, and dot-product tests.
    # TODO: Save vector files for Verilog testbenches to consume later.
    # TODO: Keep the first datasets small and easy to inspect by hand.
    _ = np
    _ = Path


if __name__ == "__main__":
    main()
