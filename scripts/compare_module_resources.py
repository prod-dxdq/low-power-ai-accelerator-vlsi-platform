"""
Script overview:
This script compares VLSI synthesis resource usage across several accelerator modules in the platform.
It reads the high-level Yosys reports, reuses the existing report parser, and creates a grouped bar chart
that shows how hardware resources scale as the accelerator architecture becomes more advanced.

In the platform, this helps beginner-friendly architecture analysis because it makes it easy to compare
smaller compute blocks against more complete accelerator designs without reading each report by hand.
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

from parse_reports import load_report_text, parse_number_of_cells


# This block defines the input reports and the output plot used for the module comparison workflow.
MODULE_REPORTS = {
    "dot_product_unit": Path("reports/dot_product_unit_high_level_report.txt"),
    "low_power_ai_accelerator": Path("reports/low_power_ai_accelerator_high_level_report.txt"),
    "ai_accelerator_core": Path("reports/ai_accelerator_core_high_level_report.txt"),
}
PLOT_PATH = Path("plots/module_resource_comparison.png")


def load_module_counts(module_name, report_path):
    """
    Function overview:
    This function loads one synthesis report, parses the Number of cells section,
    and returns the resource counts for that module.
    """

    # This block gives a helpful error when a required synthesis report has not been generated yet.
    if not report_path.exists():
        print(
            f"ERROR: Missing synthesis report for {module_name}: {report_path}\n"
            f"Generate this report first, then rerun the comparison workflow."
        )
        return None

    # This block loads the report text using the same encoding-safe helper as the existing parser.
    report_text = load_report_text(report_path)

    # This block extracts total cells and the main arithmetic/storage resource classes.
    return parse_number_of_cells(report_text)


def main():
    """
    Main script overview:
    This function loads all requested module reports, prints the parsed resource data,
    and saves a grouped bar chart that compares how the architectures scale.
    """

    # This block creates the plots directory if needed so the output image can always be saved.
    PLOT_PATH.parent.mkdir(exist_ok=True)

    # This block loads every requested report and stops early if any required file is missing.
    module_counts = {}
    for module_name, report_path in MODULE_REPORTS.items():
        counts = load_module_counts(module_name, report_path)
        if counts is None:
            return
        module_counts[module_name] = counts

    # This block prints the parsed data in the terminal before the plot is generated.
    print("Module resource data:")
    print("---------------------")
    for module_name, counts in module_counts.items():
        print(f"{module_name}:")
        print(f"  total_cells = {counts['total_cells']}")
        print(f"  mul         = {counts['mul']}")
        print(f"  add         = {counts['add']}")
        print(f"  dff         = {counts['dff']}")
        print(f"  mux         = {counts['mux']}")

    resource_labels = ["Total Cells", "Multipliers", "Adders", "Flip-flops", "Muxes"]
    resource_keys = ["total_cells", "mul", "add", "dff", "mux"]
    module_labels = list(module_counts.keys())

    # This block arranges the parsed data into grouped bars so each resource type can be compared across modules.
    x_positions = np.arange(len(resource_labels))
    bar_width = 0.24

    plt.figure(figsize=(10, 6))
    for index, module_name in enumerate(module_labels):
        values = [module_counts[module_name][key] for key in resource_keys]
        bar_positions = x_positions + ((index - 1) * bar_width)
        bars = plt.bar(bar_positions, values, width=bar_width, label=module_name)

        # This block places the numeric values above each bar so the comparison is easy to read quickly.
        for bar, value in zip(bars, values):
            plt.text(
                bar.get_x() + bar.get_width() / 2,
                value + 0.1,
                str(value),
                ha="center",
                va="bottom",
                fontsize=8,
            )

    # This block formats the plot so the grouped comparison is readable and clearly labeled.
    plt.xticks(x_positions, resource_labels)
    plt.ylabel("Count")
    plt.title("Module Resource Comparison")
    plt.legend()
    plt.tight_layout()

    # This block saves the grouped comparison chart to the requested location.
    plt.savefig(PLOT_PATH)
    plt.close()

    # This block prints a success message so the user knows where the comparison chart was written.
    print(f"Saved module comparison plot to {PLOT_PATH}")


if __name__ == "__main__":
    main()