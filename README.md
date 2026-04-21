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
mkdir -p nalog/static/canvas/$DEMO_NAME

cp out/${DEMO_NAME}.js       nalog/static/canvas/$DEMO_NAME/
cp out/${DEMO_NAME}_bg.wasm  nalog/static/canvas/$DEMO_NAME/
```

ディレクトリ構成:
```
static/canvas/
└── various_shapes/
    ├── various_shapes.js
    └── various_shapes_bg.wasm
```

### 3. デモ記事を作成

`content/canvas/<slug>.md` を作成します。

```bash
cat > nalog/content/canvas/various-shapes.md << 'EOF'
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
| `name`    | ✓    | —        | デモ名。`static/canvas/<name>/<name>.js` に対応 |
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

`zola serve` は COOP/COEP ヘッダーを返さないため、WASMの確認は `zola build` + `npx serve` で行います。

**Windows（PowerShell）:**

```powershell
# 1. wasm/ のファイルを static/demos/ にコピー
.\scripts\copy-wasm-local.ps1

# 2. ビルド
zola build --base-url http://localhost:8080

# 3. サーブ
npx serve -p 8080 public/ `
  --header "Cross-Origin-Opener-Policy: same-origin" `
  --header "Cross-Origin-Embedder-Policy: require-corp"
```

**Linux / Mac:**

```bash
# 1〜3 をまとめて実行
make serve
```

ブラウザで http://localhost:8080/canvas/dam-break/ などを開き、
Bevy の canvas が表示されることを確認します。

> `static/demos/` は `.gitignore` で除外されているためリポジトリには含まれません。
> CI（`deploy.yml`）ではWASMはR2から配信されるため、このコピー手順は不要です。

---

## デプロイ（Cloudflare Pages + GitHub Actions）

main ブランチへの push で `.github/workflows/deploy.yml` が自動実行され、
Cloudflare Pages にデプロイされます。

### 初回セットアップ

#### 1. Cloudflare Pages プロジェクトの作成

Cloudflare ダッシュボード（[dash.cloudflare.com](https://dash.cloudflare.com)）で以下の手順を実行します。

1. **Workers & Pages** → **Create** → **Pages** タブを選択
2. **Direct Upload** を選択（Git 連携は使わない）
3. プロジェクト名に `nalog` を入力して **Create project** をクリック
4. ファイルのアップロードは不要（スキップ）

> Direct Upload 方式で作成することで、GitHub Actions 側からのデプロイのみを受け付けます。

#### 2. Cloudflare API トークンの発行

1. Cloudflare ダッシュボード右上のプロフィール → **My Profile** → **API Tokens**
2. **Create Token** → **Custom token**
3. 以下の権限を設定:
   - **Permissions**: `Cloudflare Pages` — `Edit`
4. **Continue to summary** → **Create Token**
5. 表示されたトークンを控えておく（再表示不可）

#### 3. Cloudflare Account ID の確認

Cloudflare ダッシュボードで任意のドメインを選択すると、右サイドバーの
**API** セクションに **Account ID** が表示されます。

#### 4. GitHub Secrets の設定

リポジトリの **Settings** → **Secrets and variables** → **Actions** → **New repository secret** で以下を登録:

| Secret 名 | 値 |
|-----------|-----|
| `CLOUDFLARE_API_TOKEN` | 手順2で発行したAPIトークン |
| `CLOUDFLARE_ACCOUNT_ID` | 手順3で確認したAccount ID |

#### 5. デプロイの確認

main ブランチに push すると GitHub Actions が起動し、Cloudflare Pages にデプロイされます。

- GitHub: **Actions** タブでワークフローの成功を確認
- Cloudflare: **Workers & Pages** → `nalog` プロジェクトでデプロイ履歴とURLを確認

`static/_headers` により COOP/COEP ヘッダーが自動で適用されます（WASM の SharedArrayBuffer に必要）。

---

## WASMアセットのR2アップロード

WASMビルド成果物はファイルサイズが大きいため、Cloudflare Pages には含めず
Cloudflare R2 から配信します。`wasm/` 以下に変更があった push 時に
`.github/workflows/upload-wasm.yml` が自動実行されます。

### デモの追加手順

1. `wasm/<demo_name>/` にWASMビルド成果物とassetsを配置する

   ```
   wasm/
   └── various_shapes/
       ├── various_shapes.js
       ├── various_shapes_bg.wasm
       └── assets/
   ```

2. main ブランチに push すると、変更があったデモのみ R2 に自動アップロードされる

3. アップロード先URL: `https://assets.nalog.dev/<demo_name>/`

### 初回セットアップ（R2）

#### 1. R2 バケットの作成

Cloudflare ダッシュボード → **R2 Object Storage** → **Create bucket** でバケットを作成します。

#### 2. R2 API トークンの発行

**R2 Object Storage** → **Manage R2 API Tokens** → **Create API Token** で以下の権限を設定:

- **Permissions**: `Object Read & Write`
- **Specify bucket**: 作成したバケットを指定

発行された **Access Key ID** と **Secret Access Key** を控えておきます。

#### 3. GitHub Secrets の追加

| Secret 名 | 値 |
|-----------|-----|
| `R2_ACCESS_KEY_ID` | R2 API トークンのAccess Key ID |
| `R2_SECRET_ACCESS_KEY` | R2 API トークンのSecret Access Key |
| `R2_BUCKET_NAME` | 作成したバケット名 |
| `R2_ACCOUNT_ID` | Cloudflare Account ID（`CLOUDFLARE_ACCOUNT_ID` と同じ値） |

---

## ディレクトリ構成

```
nalog/
├── config.toml
├── content/
│   ├── _index.md
│   ├── blog/           # 技術記事
│   └── canvas/         # デモページ
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
│   └── css/
│       └── style.css
├── wasm/               # WASMビルド成果物（R2にアップロード）
│   └── <demo_name>/
│       ├── <demo_name>.js
│       ├── <demo_name>_bg.wasm
│       └── assets/     # デモが使用するアセット（シェーダー等）
└── .gitignore
```
