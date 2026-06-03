$repoRoot = Split-Path $PSScriptRoot -Parent
$gtkwave = (Get-Command gtkwave).Source
$bin = Split-Path $gtkwave -Parent
$root = Split-Path $bin -Parent

$env:PATH = "$bin;$root\lib;$root\lib\ivl;" + $env:PATH

$dumpFile = Join-Path $repoRoot "waves\smoke_probe.vcd"
$saveFile = Join-Path $repoRoot "waves\smoke_probe.gtkw"
$dumpInfo = Get-Item $dumpFile

$saveText = @"
[*]
[*] GTKWave Analyzer save file
[*]
[dumpfile]
"$dumpFile"
[dumpfile_mtime] "$(Get-Date $dumpInfo.LastWriteTime -Format 'ddd MMM dd HH:mm:ss yyyy')"
[dumpfile_size] $($dumpInfo.Length)
[savefile]
"$saveFile"
[timestart] 0
[size] 1100 700
[pos] -1 -1
*-3.000000 0
[sst_width] 220
[signals_width] 160
[sst_expanded] 1
[sst_vpaned_height] 180
@28
tb_smoke_probe.clk
tb_smoke_probe.rst_n
tb_smoke_probe.a
tb_smoke_probe.b
tb_smoke_probe.sel
tb_smoke_probe.y
tb_smoke_probe.dut.comb_result
"@

Set-Content -Path $saveFile -Value $saveText -Encoding ASCII

Start-Process -FilePath $gtkwave -ArgumentList @($dumpFile, $saveFile) -WorkingDirectory $repoRoot