$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$schematicsDir = Join-Path $repoRoot 'schematics'
$reportsDir = Join-Path $repoRoot 'reports'
$jsonPath = Join-Path $schematicsDir 'ai_accelerator_core.json'
$svgPath = Join-Path $schematicsDir 'ai_accelerator_core.svg'
$yosysLog = Join-Path $reportsDir 'ai_accelerator_core_yosys.log'
$netlistsvgLog = Join-Path $reportsDir 'ai_accelerator_core_netlistsvg.log'
$ossCadEnv = 'C:\Users\willi\tools\oss-cad-suite\oss-cad-suite\environment.ps1'

function Set-WhiteSvgBackground {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SvgPath
    )

    $svgText = Get-Content -Path $SvgPath -Raw

    if ($svgText -notmatch 'style="background:#ffffff"') {
        $svgText = [regex]::Replace($svgText, '<svg\b', '<svg style="background:#ffffff"', 1)
    }

    if ($svgText -notmatch '<rect width="100%" height="100%" fill="#ffffff"/>') {
        $svgText = [regex]::Replace(
            $svgText,
            '(<svg[^>]*>)',
            ('$1' + '`r`n  <rect width="100%" height="100%" fill="#ffffff"/>'),
            1
        )
    }

    Set-Content -Path $SvgPath -Value $svgText -Encoding utf8
}

New-Item -ItemType Directory -Path $schematicsDir -Force | Out-Null
New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

# This script is for VLSI-style visual architecture analysis, not for a Vivado or FPGA flow.
# The schematic shows module hierarchy and datapath structure so you can inspect how the accelerator is composed.
# Yosys elaborates the RTL structure, and netlistsvg turns that structure into a readable hardware diagram.
# The OSS CAD Suite environment provides the open-source ASIC-style tools used by this project.
& $ossCadEnv

# read_verilog loads the accelerator core and its dependent systolic-array modules.
# prep -top ai_accelerator_core elaborates the hierarchy rooted at the final AI accelerator core.
# write_json exports the elaborated structure into a format that netlistsvg can visualize.
$yosysScript = @'
read_verilog rtl/processing_element.v
read_verilog rtl/systolic_array_2x2.v
read_verilog rtl/ai_accelerator_core.v
prep -top ai_accelerator_core
write_json schematics/ai_accelerator_core.json
'@

& yosys -p $yosysScript *>&1 | Tee-Object -FilePath $yosysLog | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Yosys schematic generation failed. See $yosysLog"
}

& netlistsvg.cmd $jsonPath -o $svgPath *>&1 | Tee-Object -FilePath $netlistsvgLog | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "netlistsvg failed. See $netlistsvgLog"
}

Set-WhiteSvgBackground -SvgPath $svgPath

Write-Host "Schematic generated successfully. SVG saved to $svgPath"