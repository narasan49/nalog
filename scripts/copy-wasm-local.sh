#!/usr/bin/env bash
# wasm/ 以下のデモをローカル確認用に static/canvas/ にコピーする

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WASM_DIR="${REPO_ROOT}/wasm"
DEST_DIR="${REPO_ROOT}/static/canvas"

if [ ! -d "${WASM_DIR}" ] || [ -z "$(ls -A "${WASM_DIR}")" ]; then
    echo "Warning: wasm/ にデモディレクトリが見つかりません。wasm/<demo_name>/ を作成してください。" >&2
    exit 1
fi

for demo_path in "${WASM_DIR}"/*/; do
    [ -d "${demo_path}" ] || continue
    demo_name="$(basename "${demo_path}")"
    dest="${DEST_DIR}/${demo_name}"

    echo "Copying ${demo_name} -> static/canvas/${demo_name}"
    mkdir -p "${dest}"
    cp -r "${demo_path}"* "${dest}/"
done

echo "Done."
