# Low-Power AI Accelerator VLSI Platform

## Project Overview

This repository is a VLSI-focused AI accelerator project built around Verilog RTL design, digital simulation, waveform inspection, synthesis, schematic generation, and Python-based report analysis. The workflow stays in an ASIC/VLSI-style environment using open-source tools rather than a Vivado or FPGA-centric flow.

The project progresses from small learning modules such as counters and ALUs into accelerator-oriented datapaths such as MAC units, dot-product engines, and matrix-compute hardware. The final design is a low-power AI accelerator core based on a real 2x2 systolic array.

In practice, the repository combines:

- Verilog RTL for hardware design
- Icarus Verilog for simulation
- GTKWave for waveform verification
- Yosys for high-level synthesis
- netlistsvg-based schematic generation for hardware visualization
- Python scripts for report parsing, plotting, and architecture comparison

## Tech Stack

- Verilog
- Python
- Icarus Verilog
- GTKWave
- Yosys
- OSS CAD Suite
- matplotlib
- VS Code
- Git/GitHub

## Module Progression

| Module | Purpose | What it teaches |
| --- | --- | --- |
| Traffic Light Controller | Simple FSM-based control logic example | Basic sequential logic, state transitions, and waveform debugging |
| Counter | Small sequential counting block | Clocked logic, reset behavior, and simple state evolution |
| ALU | Arithmetic and logic datapath block | Combinational datapaths and operation selection |
| MAC Unit | Multiply-accumulate building block | How AI-style arithmetic maps into hardware primitives |
| Clock-Gated MAC | Low-power MAC variation | How clock gating can reduce unnecessary switching activity |
| Dot Product Unit | Parallel multiply-and-reduce datapath | Vector-style arithmetic and adder-tree reduction |
| Matrix Multiplier | Small matrix-compute structure | How repeated MAC-style operations scale into matrix math |
| Tiny AI Accelerator | Small accelerator wrapper around compute logic | How arithmetic blocks are composed into a larger datapath |
| Low-Power AI Accelerator | Higher-level accelerator with low-power design intent | Resource-aware architecture growth and clocked datapath structure |
| Parallel Dot Product Engine | Wider parallel compute engine | Throughput scaling using multiple arithmetic lanes |
| Processing Element | Core cell of the systolic array | Local multiply-accumulate plus data forwarding behavior |
| Real 2x2 Systolic Array | Four-PE streaming matrix engine | Real systolic dataflow with horizontal and vertical operand movement |
| AI Accelerator Core | Final top-level accelerator wrapper | How a clean top module exposes a systolic-array-based compute core |

## Final Architecture

The final hardware design is built around `ai_accelerator_core`, which wraps `systolic_array_2x2` as the compute engine.

Inside that compute engine:

- `systolic_array_2x2` contains 4 `processing_element` instances
- each processing element performs a multiply-accumulate operation
- A values stream horizontally across the array
- B values stream vertically through the array
- `c00`, `c01`, `c10`, and `c11` are the matrix multiplication outputs

This is a real systolic-dataflow structure rather than four unrelated MAC units. That matters because the timing of operand injection and forwarding is what makes the accelerator behave like matrix hardware instead of just parallel arithmetic.

## Simulation Results

The final `ai_accelerator_core` testbench was verified with simulation and GTKWave using the matrix multiply:

```text
A = [1 2]
	[3 4]

B = [5 6]
	[7 8]

C = [19 22]
	[43 50]
```

These final outputs were confirmed in waveform inspection, including the streamed operand timing and the final `c00`, `c01`, `c10`, and `c11` results in GTKWave.

## Synthesis Results

The high-level Yosys synthesis summary for `ai_accelerator_core` is:

```text
Number of cells:
total cells: 20
$mul: 4
$add: 4
$dff or $DFFE: 12
$mux: 0
```

At a beginner-friendly architecture level, this means:

- multipliers are the core compute units performing the products
- adders accumulate the multiplication results
- flip-flops store pipeline or dataflow state inside the architecture
- mux count is zero in the high-level report

This high-level report is useful because it shows the accelerator structure before lower-level gate decomposition. It is a hardware-resource view of the design rather than a software performance metric.

## Python Analysis

The repository includes Python helpers that parse Yosys reports and generate plots for resource analysis:

- `scripts/parse_reports.py`
- `scripts/plot_results.py`
- `scripts/plot_resources_improved.py`
- `scripts/compare_module_resources.py`

These scripts help turn synthesis output into readable summaries and charts so it is easier to compare how hardware resources scale as the architecture becomes more advanced.

## Visual Results

Generated hardware and analysis outputs currently include:

- `schematics/ai_accelerator_core.svg`
- `plots/ai_accelerator_core_resource_breakdown.png`
- `plots/module_resource_comparison.png`

The schematic shows the structure and hierarchy of the final accelerator hardware, while the plots show how synthesis resources are distributed within the accelerator and how they compare across modules.

## How To Run

Load the Windows OSS CAD Suite environment first:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
```

Compile the final AI accelerator core testbench:

```powershell
iverilog -o sim/ai_accelerator_core.out tb/tb_ai_accelerator_core.v rtl/ai_accelerator_core.v rtl/systolic_array_2x2.v rtl/processing_element.v
```

Run the simulation:

```powershell
vvp sim/ai_accelerator_core.out
```

Open the waveform in GTKWave:

```powershell
gtkwave waves/ai_accelerator_core.vcd
```

Run the Python report and plot analysis:

```powershell
python scripts/parse_reports.py
python scripts/plot_resources_improved.py
python scripts/compare_module_resources.py
```

## Project Story

Designed and verified a low-power AI accelerator VLSI platform in Verilog, progressing from basic digital logic blocks to a real 2x2 systolic array accelerator core. Implemented simulation, waveform verification, Yosys synthesis, schematic generation, and Python-based report parsing/visualization to analyze hardware resource usage across accelerator architectures.
