$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$schematicsDir = Join-Path $repoRoot 'schematics'
$reportsDir = Join-Path $repoRoot 'reports'

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
            ('$1' + "`r`n  <rect width=""100%"" height=""100%"" fill=""#ffffff""/>"),
            1
        )
    }

    Set-Content -Path $SvgPath -Value $svgText -Encoding utf8
}

New-Item -ItemType Directory -Path $schematicsDir -Force | Out-Null
New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

$targets = @(
    @{ Name = 'alu'; Description = 'The ALU schematic shows the arithmetic and logic datapath selected by the operation input.' },
    @{ Name = 'mac_unit'; Description = 'The MAC schematic shows a multiplier feeding an accumulator register, which is the core pattern used in AI compute blocks.' },
    @{ Name = 'clock_gated_mac'; Description = 'The clock-gated MAC schematic highlights the same MAC datapath with extra enable-gating logic that suppresses unnecessary switching.' },
    @{ Name = 'dot_product_unit'; Description = 'The dot-product schematic expands the MAC idea into several parallel multiply paths whose outputs are reduced through an adder tree.' },
    @{ Name = 'tiny_ai_accelerator'; Description = 'The tiny AI accelerator schematic shows the top-level composition of the accelerator, including the dot-product block inside the registered datapath.' }
)

$rtlSources = Get-ChildItem -Path (Join-Path $repoRoot 'rtl') -Filter '*.v' | Sort-Object Name
$rtlArguments = ($rtlSources | ForEach-Object { $_.FullName.Replace('\', '/') }) -join ' '

foreach ($target in $targets) {
    $name = $target.Name
    $jsonPath = Join-Path $schematicsDir "$name.json"
    $svgPath = Join-Path $schematicsDir "$name.svg"
    $yosysLog = Join-Path $reportsDir "${name}_yosys.log"
    $netlistsvgLog = Join-Path $reportsDir "${name}_netlistsvg.log"

    Write-Host "Generating schematic for $name..."

    # read_verilog loads the RTL sources into Yosys so it can understand the modules and their wiring.
    # prep -top selects the module to visualize and elaborates the design hierarchy below that top block.
    # write_json exports the elaborated hardware structure into a netlistsvg-friendly netlist description.
    $yosysScript = "read_verilog $rtlArguments; prep -top $name; write_json $($jsonPath.Replace('\', '/'))"
    & yosys -p $yosysScript *>&1 | Tee-Object -FilePath $yosysLog | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Yosys failed for $name. See $yosysLog"
    }

    & netlistsvg.cmd $jsonPath -o $svgPath *>&1 | Tee-Object -FilePath $netlistsvgLog | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "netlistsvg failed for $name. See $netlistsvgLog"
    }

    Set-WhiteSvgBackground -SvgPath $svgPath

    Write-Host "  Saved $svgPath"
    Write-Host "  $($target.Description)"
}

Write-Host ""
Write-Host "All schematics generated in $schematicsDir"
