# nalog

[Bevy](https://bevy.org/)/Wasmデモを公開も目的としたブログサイトです。Claudeに[Zola](https://www.getzola.org/)で作ってもらいました。

## セットアップ

```bash
# Zola のインストール (winget)
winget install getzola.zola

# ローカル開発サーバー起動
zola serve
# → http://127.0.0.1:1111
```

---

## Bevyデモの追加手順

### 1. WASMビルド

Bevy アプリ（例: [`bevy_eulerian_fluid`](https://github.com/narasan49/bevy_eulerian_fluid)）を wasm-bindgen でビルドします。

```bash
cd /path/to/bevy_eulerian_fluid

# wasm32 ターゲットを追加（初回のみ）
rustup target add wasm32-unknown-unknown

# リリースビルド
cargo build --example various_shapes --release --target wasm32-unknown-unknown

# wasm-bindgen でバインディング生成
#   --target web      : ES Module 形式で出力（Zola shortcode が import() で読み込む形式）
#   --no-typescript   : .d.ts 不要
wasm-bindgen \
  target/wasm32-unknown-unknown/release/various_shapes.wasm \
  --out-dir out/ \
  --target web \
  --no-typescript
```

生成される成果物:
```
out/
├── various_shapes.js       # ES Module（init() をエクスポート）
└── various_shapes_bg.wasm  # 本体
```

### 2. 成果物をブログにコピー

`static/demos/<demo_name>/` に配置します。

```bash
# デモ名は JS/WASM のファイル名プレフィックスに合わせる
DEMO_NAME=various_shapes
mkdir -p nalog/static/demos/$DEMO_NAME

cp out/${DEMO_NAME}.js       nalog/static/demos/$DEMO_NAME/
cp out/${DEMO_NAME}_bg.wasm  nalog/static/demos/$DEMO_NAME/
```

ディレクトリ構成:
```
static/demos/
└── various_shapes/
    ├── various_shapes.js
    └── various_shapes_bg.wasm
```

### 3. デモ記事を作成

`content/demos/<slug>.md` を作成します。

```bash
cat > nalog/content/demos/various-shapes.md << 'EOF'
+++
title = "Various Shapes デモ"
date = 2026-04-05
description = "デモの説明"
template = "demo_page.html"
[taxonomies]
tags = ["bevy", "wasm", "gamedev"]
+++

{{ bevy_demo(name="various_shapes", width="800", height="600") }}

デモの説明文をここに書く。
EOF
```

**shortcode パラメータ:**

| パラメータ | 必須 | デフォルト | 説明 |
|-----------|------|----------|------|
| `name`    | ✓    | —        | デモ名。`static/demos/<name>/<name>.js` に対応 |
| `width`   |      | `"800"`  | canvas の幅 (px) |
| `height`  |      | `"600"`  | canvas の高さ (px) |

> **Bevy側でのcanvas ID設定**
> Bevyアプリで `canvas: Some("#<name>-canvas".to_string())` を設定してください。
> ```rust
> App::new()
>     .add_plugins(DefaultPlugins.set(WindowPlugin {
>         primary_window: Some(Window {
>             canvas: Some("#various_shapes-canvas".to_string()),
>             ..default()
>         }),
>         ..default()
>     }))
> ```

### 4. 動作確認

`zola serve` は COOP/COEP ヘッダーを返さないため、WASMの確認は以下の手順で行います。

```bash
cd nalog

# ビルド（--base-url を指定しないと CSS・リンクが example.com に向く）
zola build --base-url http://localhost:8080

# ローカルサーバーで起動（static/serve.json が COOP/COEP ヘッダーを自動設定）
npx serve public -p 8080
```

ブラウザで http://localhost:8080/demos/various-shapes/ を開き、
Bevy の canvas が表示されることを確認します。

---

## デプロイ（Cloudflare Pages）

1. GitHub にリポジトリを作成してプッシュ
2. Cloudflare Pages で新規プロジェクトを作成
3. ビルド設定:
   - **Framework preset**: Zola
   - **Build command**: `zola build`
   - **Build output directory**: `public`
4. `static/_headers` により COOP/COEP ヘッダーが自動で適用されます

---

## ディレクトリ構成

```
nalog/
├── config.toml
├── content/
│   ├── _index.md
│   ├── posts/          # 技術記事
│   └── demos/          # デモページ
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── section.html
│   ├── demos_section.html  # デモ一覧ページ専用テンプレート
│   ├── page.html
│   ├── demo_page.html      # デモ詳細ページ専用テンプレート
│   ├── taxonomy_list.html
│   ├── taxonomy_single.html
│   └── shortcodes/
│       └── bevy_demo.html
├── static/
│   ├── _headers        # Cloudflare Pages COOP/COEP設定
│   ├── serve.json      # npx serve 用ヘッダー設定
│   ├── css/
│   │   └── style.css
│   └── demos/
│       └── <demo_name>/
│           ├── <demo_name>.js
│           ├── <demo_name>_bg.wasm
│           └── assets/         # デモが使用するアセット（シェーダー等）
└── .gitignore
```
