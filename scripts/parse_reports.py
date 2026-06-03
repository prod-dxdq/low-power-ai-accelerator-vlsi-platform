"""
Script overview:
This script parses the Yosys high-level synthesis report for the AI accelerator core.
It reads the "Number of cells" section and extracts hardware resource counts such as
multipliers, adders, flip-flops, muxes, and total cells.

In the platform, this script helps turn raw VLSI synthesis reports into clean data
that can later be plotted, compared, and used for ML-assisted hardware analysis.
"""

from pathlib import Path


# This block defines where the synthesis report is located.
REPORT_PATH = Path("reports/ai_accelerator_core_high_level_report.txt")


def load_report_text(report_path):
    """
    Function overview:
    PowerShell commonly writes report files as UTF-16 on Windows, which leaves NUL bytes between
    visible characters if Python reads the file with a single-byte encoding. This loader tries the
    common encodings used by the flow and normalizes the text before the parser scans it.
    """

    raw_bytes = report_path.read_bytes()

    for encoding in ("utf-16", "utf-8-sig", "utf-8", "cp1252"):
        try:
            text = raw_bytes.decode(encoding)
            break
        except UnicodeDecodeError:
            continue
    else:
        text = raw_bytes.decode("utf-8", errors="replace")

    return text.replace("\x00", "")


def parse_number_of_cells(report_text):
    """
    Function overview:
    This function searches the report text for the "Number of cells" section.
    It extracts the resource counts that matter for beginner VLSI analysis.
    """

    # This dictionary stores the hardware resource counts we find in the report.
    cell_counts = {
        "total_cells": 0,
        "mul": 0,
        "add": 0,
        "dff": 0,
        "mux": 0,
    }

    # This block splits the report into individual lines so we can scan line by line.
    lines = report_text.splitlines()

    # This flag turns on once we find the "Number of cells" section.
    inside_cell_section = False

    for line in lines:
        clean_line = line.strip()

        # This block detects the start of the easy-to-find report section.
        if clean_line == "Number of cells":
            inside_cell_section = True
            continue

        # This block only parses lines after the "Number of cells" header.
        if inside_cell_section:
            if clean_line.startswith("total cells:"):
                cell_counts["total_cells"] = int(clean_line.split(":")[1].strip())

            elif clean_line.startswith("$mul:"):
                cell_counts["mul"] = int(clean_line.split(":")[1].strip())

            elif clean_line.startswith("$add:"):
                cell_counts["add"] = int(clean_line.split(":")[1].strip())

            elif clean_line.startswith("$dff") or clean_line.startswith("$DFFE"):
                cell_counts["dff"] = int(clean_line.split(":")[1].strip())

            elif clean_line.startswith("$mux:"):
                cell_counts["mux"] = int(clean_line.split(":")[1].strip())

    return cell_counts


def main():
    """
    Main script overview:
    This function loads the report, parses the cell counts, and prints a clean summary.
    """

    # This block checks that the report file actually exists before trying to read it.
    if not REPORT_PATH.exists():
        print(f"ERROR: Could not find report file: {REPORT_PATH}")
        return

    # This block reads the full Yosys report as text.
    report_text = load_report_text(REPORT_PATH)

    # This block extracts the useful hardware resource counts.
    cell_counts = parse_number_of_cells(report_text)

    # This block prints the cleaned-up synthesis summary.
    print("AI Accelerator Core - VLSI Resource Summary")
    print("-------------------------------------------")
    print(f"Total cells:     {cell_counts['total_cells']}")
    print(f"Multipliers:     {cell_counts['mul']}")
    print(f"Adders:          {cell_counts['add']}")
    print(f"Flip-flops:      {cell_counts['dff']}")
    print(f"Muxes:           {cell_counts['mux']}")


if __name__ == "__main__":
    main()