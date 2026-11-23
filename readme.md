# Neodymium Shaders (WIP)

色々適当ですがChatGPTでシェーダーを作ってみました。ちなみにGLSL初心者です  
現時点で全体的に表現バニラ調シェーダーです。影の投影、それっぽい色合いといった技術だけで作ってみました。なのでリアルすぎるのが苦手な人にはおすすめできます。  
現時点で実用的に使えるかと言われると微妙なところです。お試し程度で  
今後色々勉強しながら発展させて行きたいと思います🔥  

![スクショ1](/.screenshots/1.png) <br>
![スクショ2](/.screenshots/2.png) <br>
## 進捗

### 実装済みの機能
- Ambient Lighting
- Day/Night Lighting
- Shadow Mapping
- Shadow Distortion
- Shadow Bias
- PCF Soft Shadows

### バグ、問題のメモ
- Shadow Biasの調整が不十分でシャドウアクネが発生する
- エンティティ透ける
- コード理解しきれてない (理解したものから改善、コメント化するなどして整理していきます)

## 現時点の動作状況


### パフォーマンス

| GPU | FHD (1080p) | WQHD (1440p) | 4K (2160p) |
| :--- | ---: | :---: | :---: |
| RTX5070 | 平均240-360 fps | 未測定 | 未測定 |
| GTX1050Ti | 平均165 fps | 未測定 | 未測定 |
