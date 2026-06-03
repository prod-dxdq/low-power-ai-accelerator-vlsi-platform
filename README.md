# Low-Power AI Accelerator VLSI Platform

This project explores how to build and evaluate a low-power AI accelerator at the RTL level using Verilog, Python automation, simulation, synthesis, waveform visualization, and power-oriented hardware techniques. The focus is on turning core AI math workloads into digital hardware blocks that can be tested, visualized, and optimized for efficiency.

## Highlights

- Designs accelerator-oriented RTL blocks such as ALUs, MAC units, dot-product engines, and matrix computation hardware
- Uses Icarus Verilog and GTKWave to verify behavior and inspect timing or state activity
- Uses Yosys and netlistsvg to convert RTL into visual hardware schematics
- Uses Python to automate simulation runs, reporting, plotting, and power-analysis workflows
- Studies low-power techniques such as clock gating, switching activity reduction, and power-performance tradeoffs

## Project overview

The project targets hardware that takes input values and weights, performs repeated multiply-accumulate operations, and scales those operations into dot products and matrix multiplication. Those computations are central to many machine-learning inference pipelines, which makes them a useful foundation for accelerator architecture work.

Rather than approaching AI only at the software level, this repository models the computation as digital hardware: datapaths, control logic, MAC-based building blocks, synthesized netlists, waveform traces, and analysis reports. The low-power direction centers on reducing wasted switching and unnecessary activity, starting with clock gating and later expanding toward broader power-performance analysis.

## What the AI accelerator does

At a practical level, the accelerator is meant to ingest input values and weights, run repeated multiply-accumulate operations, and assemble those results into higher-level computations such as dot products and matrix multiplication. In other words, it turns the core math behind inference workloads into dedicated hardware so the computation can be observed, verified, and optimized directly at the circuit level.

The repository is organized around a staged hardware progression:

1. Traffic light controller
2. Counter and FSM
3. ALU
4. MAC
5. Clock-gated MAC
6. Dot-product unit
7. Matrix multiplier
8. Tiny AI accelerator
9. Low-power AI accelerator
10. Systolic array

The first two items are included primarily as validation exercises for workflow setup, FSM verification, and simulation infrastructure. The main project focus begins with arithmetic datapath design and scales toward AI accelerator hardware.

## Technical scope

- RTL design for arithmetic datapaths and accelerator building blocks
- Verification through simulation, testbenches, and waveform inspection
- Schematic generation and synthesis-driven hardware visualization
- Python automation for experiments, reports, plots, and analysis
- Low-power exploration through clock gating, switching activity, and power-performance comparisons
- Future extension into ASIC physical design with OpenROAD, Magic, KLayout, and SKY130

## Tooling roadmap

### Current tools

- VS Code
- Verilog
- Python
- NumPy and matplotlib
- Icarus Verilog
- GTKWave
- Yosys and netlistsvg

### Later tools

- SystemVerilog
- OpenROAD
- Magic and KLayout
- SkyWater SKY130 PDK
- scikit-learn and PyTorch

## Repository layout

- rtl/: RTL modules ranging from validation exercises to accelerator building blocks
- tb/: testbench skeletons for each RTL stage
- scripts/: Python helpers for simulation, schematics, vectors, reports, power, and plots
- sim/: compiled simulation artifacts
- waves/: waveform outputs for GTKWave
- schematics/: rendered netlists and diagrams
- reports/: synthesis, timing, and power summaries
- plots/: charts for performance and power exploration
- docs/: learning notes and future design documentation
- ml/: later machine-learning side experiments

## Hardware Visualization

RTL is a hardware description, not a software flowchart. Each Verilog module in this repository describes actual structures such as combinational logic, registers, adders, multipliers, control signals, and datapath connections.

Yosys converts that RTL into an elaborated hardware representation. In practice, that means it reads the Verilog, resolves the module hierarchy, prepares the chosen top module, and emits a structural netlist that schematic tools can draw.

The generated schematics make the architecture easier to inspect visually. They show where multipliers, adders, registers, muxes, and datapath connections appear inside blocks such as the ALU, MAC, clock-gated MAC, dot-product unit, and tiny AI accelerator.

These visualizations are useful when comparing accelerator building blocks because they expose how the architecture scales from a small arithmetic unit into a more complete AI datapath. They make it easier to see reuse patterns such as multiply-accumulate structure, parallel multiply paths, reduction logic, and top-level registered data movement.

To generate the current accelerator schematics in one command after loading the OSS CAD Suite environment:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
.\scripts\generate_schematics.ps1
```

The script writes these outputs into `schematics/`:

- `schematics/alu.svg`
- `schematics/mac_unit.svg`
- `schematics/clock_gated_mac.svg`
- `schematics/dot_product_unit.svg`
- `schematics/tiny_ai_accelerator.svg`

## Status

The repository currently provides the project structure, toolchain setup, and placeholder source files. The implementation work for the Verilog RTL and Python automation is intentionally left open so the hardware architecture, verification flow, and analysis pipeline can be developed directly within the platform.

## Simulation workflow

- `Run Simulation` expects matching files at `rtl/<target>.v` and `tb/tb_<target>.v`.
- `Open Waveform` reruns the selected target, generates a GTKWave savefile from the emitted VCD, and opens the waveform with the dumped signals preloaded.
- Testbenches should use the `VCD_FILE` macro pattern so the automation can direct waveform output consistently.

## How to run

### Prerequisites

- Python 3 installed and available on `PATH`
- OSS CAD Suite installed with `iverilog`, `vvp`, `gtkwave`, and `yosys`
- Python packages from `requirements.txt`

### One-time setup

Install the Python dependencies:

```powershell
python -m pip install -r requirements.txt
```

You can also run the VS Code task `Install Python Dependencies`.

If you are running from a normal PowerShell window outside VS Code tasks, load the OSS CAD Suite environment first:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
```

### Run from VS Code tasks

Use the built-in tasks in `.vscode/tasks.json`.

1. Run `Run Simulation`
2. Enter a target name such as `traffic_light_controller` or `smoke_probe`
3. Run `Open Waveform` to regenerate the waveform and open GTKWave with the dumped signals preloaded
4. Optionally run `Generate Schematic`, `Synthesize RTL`, `Plot Results`, or `Analyze Power`

The task target must match both of these files:

- `rtl/<target>.v`
- `tb/tb_<target>.v`

### Run from the command line

Typical PowerShell session:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
python -m pip install -r requirements.txt
python scripts/run_sim.py traffic_light_controller
python scripts/open_wave.py traffic_light_controller
```

Raw commands for any target:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
$target = "clock_gated_mac"
iverilog -o "sim/$target.out" "tb/tb_$target.v" "rtl/$target.v"
vvp "sim/$target.out"
gtkwave "waves/$target.vcd"
```

Example exactly like the manual flow above:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
iverilog -o sim/clock_gated_mac.out tb/tb_clock_gated_mac.v rtl/clock_gated_mac.v
vvp sim/clock_gated_mac.out
gtkwave waves/clock_gated_mac.vcd
```

If you want the repo's synced GTKWave flow instead of opening the raw `.vcd` directly:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
python scripts/run_sim.py clock_gated_mac
python scripts/open_wave.py clock_gated_mac
```

Manual command templates by step:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
$target = "traffic_light_controller"
```

Compile RTL and testbench into a simulation binary:

```powershell
iverilog -o "sim/$target.out" "tb/tb_$target.v" "rtl/$target.v"
```

Run the compiled simulation with `vvp`:

```powershell
vvp "sim/$target.out"
```

Open GTKWave directly on the waveform file:

```powershell
gtkwave "waves/$target.vcd"
```

Open GTKWave using the repo's auto-generated savefile flow:

```powershell
python scripts/open_wave.py $target
```

Compile and run a simulation:

```powershell
python scripts/run_sim.py traffic_light_controller
```

Open the waveform using the generated VCD and an auto-generated GTKWave savefile:

```powershell
python scripts/open_wave.py traffic_light_controller
```

Run a different target by replacing the target name, for example:

```powershell
python scripts/run_sim.py smoke_probe
python scripts/open_wave.py smoke_probe
```

Generate a schematic:

```powershell
python scripts/generate_schematic.py traffic_light_controller
```

Example for the dot-product unit:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
python scripts/generate_schematic.py dot_product_unit
```

Manual schematic flow for any target:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
$target = "dot_product_unit"
yosys -p "read_verilog rtl/$target.v; prep -top $target; write_json schematics/$target.json"
netlistsvg.cmd "schematics/$target.json" -o "schematics/$target.svg"
```

If you want to use the interactive Yosys prompt instead, first start Yosys from PowerShell:

```powershell
& "C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1"
yosys
```

Then enter the Yosys commands at the `yosys>` prompt, not at the `PS>` PowerShell prompt:

```tcl
read_verilog rtl/dot_product_unit.v
prep -top dot_product_unit
write_json schematics/dot_product_unit.json
```

Synthesize an RTL file with Yosys:

```powershell
yosys -p "read_verilog rtl/traffic_light_controller.v; synth; stat"
```

Plot aggregated results:

```powershell
python scripts/plot_results.py
```

Run power-analysis helpers:

```powershell
python scripts/analyze_power.py
```

### Outputs

- Compiled simulation outputs are written to `sim/`
- Waveforms are written to `waves/`
- Generated GTKWave savefiles are written to `waves/<target>.gtkw`
- Schematics are written to `schematics/`
- Reports are written to `reports/`
- Plots are written to `plots/`

### Testbench expectations

- Each runnable target should have `rtl/<target>.v` and `tb/tb_<target>.v`
- Each testbench should emit a VCD with `$dumpfile` and `$dumpvars`
- The preferred pattern is the `VCD_FILE` macro used by the existing testbenches so automation can direct wave output consistently
