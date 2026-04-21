# wasm/ 以下のデモをローカル確認用に static/demos/ にコピーする

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WasmDir  = Join-Path $RepoRoot "wasm"
$DestDir  = Join-Path $RepoRoot "static\canvas"

$demos = Get-ChildItem -Path $WasmDir -Directory -ErrorAction SilentlyContinue

if (-not $demos) {
    Write-Warning "wasm/ にデモディレクトリが見つかりません。wasm/<demo_name>/ を作成してください。"
    exit 1
}

foreach ($demo in $demos) {
    $src  = $demo.FullName
    $dest = Join-Path $DestDir $demo.Name

    Write-Host "Copying $($demo.Name) -> static/demos/$($demo.Name)"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
}

Write-Host "Done."
