from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Parse placeholder synthesis reports.")
    parser.add_argument("report", nargs="?", default="reports/example.rpt")
    parser.parse_args()

    # TODO: Extract timing, area, and cell-count summaries from reports.
    # TODO: Emit a compact JSON summary for plotting and comparison.
    # TODO: Keep the parser simple until real reports are available.
    _ = json
    _ = Path


if __name__ == "__main__":
    main()
