$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$reportsDir = Join-Path $repoRoot 'reports'
$reportPath = Join-Path $reportsDir 'ai_accelerator_core_high_level_report.txt'
$ossCadEnv = 'C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1'

New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

# This script is for VLSI-style high-level architecture analysis, not for a Vivado or FPGA flow.
# The synthesis report shows the hardware resources that Yosys sees in the RTL before techmapping.
# That makes it useful for understanding datapath structure, arithmetic blocks, and storage at the architecture level.
# The OSS CAD Suite environment provides the ASIC-oriented open-source tools used by this project.
& $ossCadEnv

# read_verilog loads the top module and its required dependencies into Yosys.
# hierarchy -top ai_accelerator_core selects the accelerator core as the synthesis root.
# proc, opt, and fsm convert behavioral RTL into Yosys's internal representation and simplify it.
# stat prints the high-level hardware resource summary that we save as a report.
$yosysScript = @'
read_verilog rtl/processing_element.v
read_verilog rtl/systolic_array_2x2.v
read_verilog rtl/ai_accelerator_core.v
hierarchy -top ai_accelerator_core
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
    'This high-level summary is for VLSI architecture review.',
    'It shows hardware resources before lower-level decomposition into generic gate-style structures.'
)

Add-Content -Path $reportPath -Value $appendBlock

Write-Host "High-level synthesis completed successfully. Report saved to $reportPath"