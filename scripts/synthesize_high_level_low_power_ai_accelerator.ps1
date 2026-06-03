$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$reportsDir = Join-Path $repoRoot 'reports'
$reportPath = Join-Path $reportsDir 'low_power_ai_accelerator_high_level_report.txt'
$ossCadEnv = 'C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1'

New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

& $ossCadEnv

# This report is meant for high-level architectural analysis, so it intentionally stops before techmap.
# The older techmapped report is better for lower-level gate-oriented analysis after generic arithmetic has been decomposed.
# read_verilog loads the RTL source files into Yosys so both the top module and its dependent submodule are available.
# hierarchy -top selects low_power_ai_accelerator as the synthesis root and resolves the referenced design hierarchy beneath it.
# proc converts behavioral always blocks and process logic into Yosys's internal netlist representation.
# opt removes redundant logic and simplifies the design while preserving the higher-level cell structure.
# fsm detects and optimizes finite-state-machine style logic if any is present in the design.
# stat prints the design statistics that we use for the architecture-level cell summary.
$yosysScript = @'
read_verilog rtl/dot_product_unit.v
read_verilog rtl/low_power_ai_accelerator.v
hierarchy -top low_power_ai_accelerator
proc
opt
fsm
opt
stat
'@

& yosys -p $yosysScript *>&1 | Tee-Object -FilePath $reportPath | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "High-level synthesis failed. See $reportPath"
}

$reportLines = Get-Content -Path $reportPath
$statsStart = $reportLines.IndexOf('=== design hierarchy ===')
if ($statsStart -lt 0) {
    throw "Could not find the design hierarchy statistics section in $reportPath"
}

$summaryLines = $reportLines[$statsStart..($reportLines.Length - 1)]

function Get-CellCount {
    param(
        [string[]]$Lines,
        [string[]]$Names
    )

    foreach ($name in $Names) {
        $match = $Lines | Where-Object { $_ -match ('^\s*(\d+)\s+' + [regex]::Escape($name) + '$') } | Select-Object -First 1
        if ($match) {
            return [int]([regex]::Match($match, '^\s*(\d+)').Groups[1].Value)
        }
    }

    return 0
}

$totalCells = Get-CellCount -Lines $summaryLines -Names @('cells')
$mulCells = Get-CellCount -Lines $summaryLines -Names @('$mul')
$addCells = Get-CellCount -Lines $summaryLines -Names @('$add')
$dffCells = Get-CellCount -Lines $summaryLines -Names @('$dff', '$adff', '$dffe', '$adffe')
$muxCells = Get-CellCount -Lines $summaryLines -Names @('$mux')

$appendBlock = @(
    '',
    '============================================================',
    'Number of cells',
    '============================================================',
    "total cells: $totalCells",
    "`$mul: $mulCells",
    "`$add: $addCells",
    "`$dff or `$DFFE: $dffCells",
    "`$mux: $muxCells",
    '============================================================',
    'This section summarizes the high-level architectural cells before techmapping.',
    'Use the techmapped report when you want lower-level gate-style counts instead.'
)

Add-Content -Path $reportPath -Value $appendBlock

Write-Host "High-level synthesis completed successfully. Report saved to $reportPath"