.PHONY: serve build

# WASMをコピーしてビルド・サーブ（ローカル動作確認用）
# Windows の場合: PowerShell で scripts/copy-wasm-local.ps1 を実行してから make build serve-only
serve:
	bash scripts/copy-wasm-local.sh
	zola build --base-url http://localhost:8080
	npx serve -p 8080 public/ \
		--header "Cross-Origin-Opener-Policy: same-origin" \
		--header "Cross-Origin-Embedder-Policy: require-corp"

build:
	zola build --base-url http://localhost:8080

serve-only:
	npx serve -p 8080 public/ \
		--header "Cross-Origin-Opener-Policy: same-origin" \
		--header "Cross-Origin-Embedder-Policy: require-corp"
