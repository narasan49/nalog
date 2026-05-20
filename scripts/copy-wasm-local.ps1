# wasm/ 以下のデモをローカル確認用に static/canvas/ にコピーする
# videos/ 以下の動画ファイルをローカル確認用に static/videos/ にコピーする

$RepoRoot  = Split-Path -Parent $PSScriptRoot
$WasmDir   = Join-Path $RepoRoot "wasm"
$DestDir   = Join-Path $RepoRoot "static\canvas"
$VideoSrc  = Join-Path $RepoRoot "videos"
$VideoDest = Join-Path $RepoRoot "static\videos"

$demos = Get-ChildItem -Path $WasmDir -Directory -ErrorAction SilentlyContinue

if (-not $demos) {
    Write-Warning "wasm/ にデモディレクトリが見つかりません。wasm/<demo_name>/ を作成してください。"
    exit 1
}

foreach ($demo in $demos) {
    $src  = $demo.FullName
    $dest = Join-Path $DestDir $demo.Name

    Write-Host "Copying $($demo.Name) -> static/canvas/$($demo.Name)"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item -Path "$src\*" -Destination $dest -Recurse -Force
}

$videoFiles = Get-ChildItem -Path "$VideoSrc\*" -Include "*.mp4", "*.webm" -ErrorAction SilentlyContinue

if ($videoFiles) {
    Write-Host "Copying videos -> static/videos/"
    New-Item -ItemType Directory -Force -Path $VideoDest | Out-Null
    foreach ($video in $videoFiles) {
        Copy-Item -Path $video.FullName -Destination $VideoDest -Force
    }
} else {
    Write-Host "No video files found in videos/, skipping."
}

Write-Host "Done."