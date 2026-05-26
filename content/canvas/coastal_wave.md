+++
title = "Coastal wave"
date = 2026-05-26
description = ""
template = "demo_page.html"
path = "canvas/coastal_wave"
[extra]
thumbnail = "/canvas/coastal_wave/thumbnail.png"
thumbnail_alt = "Coastal wave"
description = "波打ち際で砕波する水のシミュレーション"
preview_video = "/canvas/coastal_wave/preview.webm"

[taxonomies]
tags = ["bevy", "wasm", "gamedev"]
+++

{{ bevy_demo(name="coastal_wave", width="800", height="600") }}

## このデモについて

[Bevy](https://bevyengine.org/) エンジンで開発した、グリッドベースの2次元流体シミュレーション[bevy_eulerian_fluid](https://github.com/narasan49/bevy_eulerian_fluid)の[coastal_wave](https://github.com/narasan49/bevy_eulerian_fluid/blob/main/examples/coastal_wave.rs) exampleのWebAssemblyビルドです。

水深に傾斜のある状況で波を起こすシミュレーションです。水深が深いところから浅いところへ伝播する波が浅瀬で砕波する様子を観察できます。