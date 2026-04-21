+++
title = "Dam break"
date = 2026-04-21
description = ""
template = "demo_page.html"
path = "demos/dam_break"
[extra]
thumbnail = "/demos/dam_break/thumbnail.png"
thumbnail_alt = "Dam break"
description = "自由表面・剛体との相互作用のある2D流体シミュレーション"
preview_video = "/demos/dam_break/preview.webm"

[taxonomies]
tags = ["bevy", "wasm", "gamedev"]
+++

{{ bevy_demo(name="dam_break", width="800", height="600") }}

## このデモについて

[Bevy](https://bevyengine.org/) エンジンで開発した、グリッドベースの2次元流体シミュレーション[bevy_eulerian_fluid](https://github.com/narasan49/bevy_eulerian_fluid)の[dam_break](https://github.com/narasan49/bevy_eulerian_fluid/blob/main/examples/dam_break.rs) exampleのWebAssemblyビルドです。

勢いのある水面の動きや剛体と流体の相互作用を楽しむことができます。