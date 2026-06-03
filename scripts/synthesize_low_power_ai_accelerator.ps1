$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$reportsDir = Join-Path $repoRoot 'reports'
$reportPath = Join-Path $reportsDir 'low_power_ai_accelerator_synth_report.txt'
$ossCadEnv = 'C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1'

New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

& $ossCadEnv

# read_verilog loads the Verilog RTL sources into Yosys so the synthesizer can parse the design modules.
# hierarchy -top selects low_power_ai_accelerator as the synthesis root and resolves the referenced submodules under it.
# proc converts behavioral process blocks such as always blocks into a lower-level internal representation.
# opt removes redundant logic and simplifies the intermediate design after each major transformation step.
# fsm detects and optimizes finite-state-machine style logic when present in the design.
# techmap rewrites generic synthesized structures into implementation-oriented building blocks that Yosys understands well.
# stat prints a synthesis summary so the report shows cells, wires, and other structural design statistics.
$yosysScript = @'
read_verilog rtl/dot_product_unit.v
read_verilog rtl/low_power_ai_accelerator.v

hierarchy -top low_power_ai_accelerator

proc
opt
fsm
opt
techmap
opt

stat
'@

& yosys -p $yosysScript *>&1 | Tee-Object -FilePath $reportPath | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Synthesis failed. See $reportPath"
}

Write-Host "Synthesis completed successfully. Report saved to $reportPath"