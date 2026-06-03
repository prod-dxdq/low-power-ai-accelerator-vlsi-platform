"""
Script overview:
This script creates an improved VLSI resource breakdown plot for the AI accelerator core.
It reads the high-level Yosys synthesis report, reuses the existing report parser,
and visualizes only the detailed hardware resource types that are useful for beginner analysis.

In the platform, this gives a clearer architecture view because it removes the total-cell bar,
which would otherwise dominate the chart and make the individual resource categories harder to compare.
"""

from pathlib import Path

import matplotlib.pyplot as plt

from parse_reports import load_report_text, parse_number_of_cells


# This block defines where the synthesis report is read from and where the improved plot is saved.
REPORT_PATH = Path("reports/ai_accelerator_core_high_level_report.txt")
PLOT_PATH = Path("plots/ai_accelerator_core_resource_breakdown.png")


def main():
    """
    Main script overview:
    This function loads the synthesis report, extracts the detailed resource counts,
    and saves a bar chart that focuses on the categories that matter most for architecture review.
    """

    # This block makes sure the plots folder exists before we try to save the PNG file.
    PLOT_PATH.parent.mkdir(exist_ok=True)

    # This block checks that the report exists so the user gets a clear error instead of a traceback.
    if not REPORT_PATH.exists():
        print(f"ERROR: Could not find report file: {REPORT_PATH}")
        return

    # This block loads the report text using the same encoding-safe helper used by the parser.
    report_text = load_report_text(REPORT_PATH)

    # This block extracts only the resource counts we want to visualize.
    counts = parse_number_of_cells(report_text)

    labels = ["Multipliers", "Adders", "Flip-flops", "Muxes"]
    values = [
        counts["mul"],
        counts["add"],
        counts["dff"],
        counts["mux"],
    ]

    # This block builds a clearer resource plot without total cells so the detailed bars stay readable.
    plt.figure(figsize=(8, 5))
    bars = plt.bar(labels, values, color=["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728"])
    plt.title("AI Accelerator Core Resource Breakdown")
    plt.ylabel("Count")
    plt.ylim(0, max(values + [1]) + 2)

    # This block writes the numeric count above each bar so the plot is easy to read at a glance.
    for bar, value in zip(bars, values):
        plt.text(
            bar.get_x() + bar.get_width() / 2,
            value + 0.1,
            str(value),
            ha="center",
            va="bottom",
        )

    plt.tight_layout()

    # This block saves the improved plot to the requested output path.
    plt.savefig(PLOT_PATH)
    plt.close()

    # This block prints a success message so the user knows exactly where the plot was saved.
    print(f"Saved improved resource plot to {PLOT_PATH}")


if __name__ == "__main__":
    main()