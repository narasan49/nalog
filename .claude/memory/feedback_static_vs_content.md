---
name: Zolaのstatic/とcontent/の使い分け
description: 画像・WASMなどの静的アセットはstatic/に置く。content/はMarkdownのみ。
type: feedback
---

画像・JS・WASMなどの静的ファイルは `static/` に配置する。`content/` はMarkdownファイル専用であり、Zolaは `content/` 内の非Markdownファイルを配信しない。

**Why:** `content/demos/various_shapes/thumbnail.png` に置いたサムネイルが表示されない問題が発生。`static/demos/various_shapes/thumbnail.png` に移動したら解決した。

**How to apply:** ユーザーがアセット（画像・フォント・WASMなど）を追加する際、配置先が `content/` になっていないか確認する。
