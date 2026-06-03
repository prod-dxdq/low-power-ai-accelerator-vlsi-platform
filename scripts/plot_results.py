"""
Script overview:
This script plots the AI accelerator core synthesis resource counts.
It turns parsed VLSI report data into a simple bar chart showing total cells,
multipliers, adders, flip-flops, and muxes.

In the platform, this helps visualize how much hardware the accelerator uses.
"""

from pathlib import Path
import matplotlib.pyplot as plt

from parse_reports import load_report_text, parse_number_of_cells


# This block defines input/output file paths.
REPORT_PATH = Path("reports/ai_accelerator_core_high_level_report.txt")
PLOT_PATH = Path("plots/ai_accelerator_core_resources.png")

def main():
    """
    Main script overview:
    This function reads the synthesis report, extracts cell counts, and saves a plot.
    """

    # This block makes sure the plots folder exists.
    PLOT_PATH.parent.mkdir(exist_ok=True)

    # This block reads the Yosys report.
    report_text = load_report_text(REPORT_PATH)

    # This block gets the hardware resource counts.
    counts = parse_number_of_cells(report_text)

    labels = ["Total", "Mul", "Add", "DFF", "Mux"]
    values = [
        counts["total_cells"],
        counts["mul"],
        counts["add"],
        counts["dff"],
        counts["mux"],
    ]

    # This block creates the bar chart.
    plt.figure()
    plt.bar(labels, values)
    plt.title("AI Accelerator Core Resource Usage")
    plt.ylabel("Count")
    plt.tight_layout()

    # This block saves the chart
    plt.savefig(PLOT_PATH)
    print(f"Saved plot to {PLOT_PATH}")

if __name__ == "__main__":
    main()