+++
title = "Flow around circle"
date = 2026-04-21
description = ""
template = "demo_page.html"
path = "canvas/flow_around_circle"
[extra]
thumbnail = "/canvas/flow_around_circle/thumbnail.png"
thumbnail_alt = "Flow around circle"
description = "円柱周りの流れのシミュレーション"
preview_video = "/canvas/flow_around_circle/preview.webm"

[taxonomies]
tags = ["bevy", "wasm", "gamedev"]
+++

{{ bevy_demo(name="flow_around_circle", width="800", height="600") }}

## このデモについて

[Bevy](https://bevyengine.org/) エンジンで開発した、グリッドベースの2次元流体シミュレーション[bevy_eulerian_fluid](https://github.com/narasan49/bevy_eulerian_fluid)の[flow_around_circle](https://github.com/narasan49/bevy_eulerian_fluid/blob/main/examples/flow_around_circle.rs) exampleのWebAssemblyビルドです。

渦度($\nabla \times \boldsymbol{u}$)を描画し、障害物周りの流れの下流にできるカルマン渦を可視化しています。