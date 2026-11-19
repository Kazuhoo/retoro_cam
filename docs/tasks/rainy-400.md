# 実装指示書：6台目のカメラ RAINY 400

仕様は `docs/spec.md`（§9 カメラ、§15 課金）が正。この文書は、そのための作業の手順と、見落としやすい場所のまとめです。

## いつやるか

- **M8（画面構成の変更）を main にマージした後**に行う。M8 の途中には混ぜない。
- 作業ブランチ：`camera/rainy-400`（origin にある）を main にマージしてから、`milestone/rainy-400` を切って実装する。
  - マージで `docs/spec.md` と `docs/mockups/` が衝突したら、**M8 で直した内容（§9 の書体ライセンス、§16 の SKAdNetwork など）と、RAINY 400 の追加の両方を残す**。
- 「9. 質感と配色」（M9）より前でも後でもよい。M9 が先なら、RAINY 400 にも同じ質感を当てる。

## RAINY 400 の中身

| 項目 | 値 |
|---|---|
| ID | `rainy`（`CameraID.rainy`） |
| 名前 | RAINY 400 |
| ねらい | 90年代の雨の日と蛍光灯の部屋。青緑に寄った浅い色、黒が浮いたマットな仕上がり |
| 価格 | $0.99（非消耗型） |
| Product ID | `<bundle id>.camera.rainy400` |
| 4台セット | **含めない** |
| 書体 | Major Mono Display（OFL）。PostScript 名 `MajorMonoDisplay-Regular` |
| LUT | `Resources/LUTs/RAINY_400.cube` |
| 粒子 / 粒子の大きさ / 周辺減光 | 0.034 / 1.5 / 0.12 |

テーマ（撮影画面の色）

| body | text | sub | button | accent | onAccent | dot | band | stripes |
|---|---|---|---|---|---|---|---|---|
| #4F7F7A | #F4F1E6 | #D5E3DE | #253E3C | #EAD9A0 | #1F2C2A | #EAD9A0 | #253E3C | #EAD9A0, #9CC4BC |

封筒：本体 #4F7F7A、ふた #44706B、帯 #253E3C

カードと購入画面の文言

- 一言（summary）：「雨の日と蛍光灯の、浅い色」
- 説明（detail）：「雨の日と、蛍光灯の部屋。青緑に寄った浅い色と、黒の浮いたマットな仕上がりの、90年代の写り。」
- カードの表：ISO 400、粒子「ふつう」、「青緑、マットな黒」、90年代
- 作例の仮の色（M7 と同じ形式。実際の写真が来たら差し替える）：(0xA7B8B0, 0x3C4A47), (0xB6BFB4, 0x46524E), (0x9AAEA8, 0x34423F)
- 袋の文字色（packText）：#F4F1E6

## 作業の一覧

M7 時点のコードで、カメラごとに `switch` している場所です。`CameraID` に `case rainy` を足すと、ほとんどはコンパイルエラーで見つかります。

1. **`Film/FilmLook.swift`**
   - `enum CameraID` に `rainy` を追加（`allCases` の最後。カードの束で No.06 になる）
   - `FilmLook(lutName: "RAINY_400", grain: 0.034, grainSize: 1.5, vignette: 0.12)`
2. **`App/CameraTheme.swift`**：上のテーマの表と、書体 `MajorMonoDisplay-Regular`
3. **`Film/CameraCatalog.swift`**：summary、detail、samples、packText
4. **`Screens/Shared/EnvelopeView.swift`**：封筒の色
5. **`Purchases/ProductCatalog.swift`**（**要注意**）
   - `suffix` に `.camera(.rainy): "rainy400"`
   - 今は 4台セットが `CameraID.paid`（無料以外の全部）を開ける作りになっている。**このままだと RAINY 400 もセットに入ってしまう**ので、セットの中身を明示する：
     ```swift
     static let bundleCameras: [CameraID] = [.charcoal, .pool, .green, .party]
     ```
     `StoreItem.bundle.unlocks` は `Set(bundleCameras)` にする。
   - 同じく `CameraID.paid` を「セットの4台」の意味で使っている場所を `bundleCameras` に置き換える：
     - `Screens/Purchase/FoilPackView.swift`（銀の袋のストライプ、袋から出る4台）
     - `Screens/Purchase/PurchaseDoneView.swift`（4台が横一列に飛び出す）
   - `StoreItem.all` は `CameraID.paid`（RAINY 400 を含む全部の有料カメラ）＋ `.bundle` のままでよい。
6. **4台セットのボタンの表示条件**（`Screens/FilmLoad/FilmLoadModel.swift` の `showsBundle`）
   - 今は「何も買っていないとき」。仕様を「**セットの4台を1台も買っていないとき**」に変えた（RAINY 400 だけ買った人にもセットを見せる）。
   - 4台のどれかを買っていたら出さない。
7. **広告**：どれか1つでも買ったら広告を出さない、は今のまま（RAINY 400 を買った人も広告なし）。
8. **`RetoroCam.storekit`**：非消耗型を1つ追加（displayPrice 0.99、ja_JP「RAINY 400」「使い捨てカメラ RAINY 400」、en_US「RAINY 400」「Disposable camera RAINY 400」）。
9. **書体**
   - `Resources/Fonts/MajorMonoDisplay-Regular.ttf` と `MajorMonoDisplay-LICENSE.txt` は追加済み。Xcode のターゲットに入れる。
   - `Config/Info.plist` の `UIAppFonts` に追加。
   - `Screens/Settings/LicensesScreen.swift` に `Entry(name: "Major Mono Display", file: "MajorMonoDisplay-LICENSE")`。
10. **LUT**：`Resources/LUTs/RAINY_400.cube` をターゲットに入れる（`LUTLoader` で読めることを確認）。
11. **デバッグ欄**：「全部購入済み」で RAINY 400 も使えること。
12. **文言**：`Localizable.xcstrings` に新しい文言を追加。
13. **立体のカメラ（M8-6）**：テーマから6面の画像を作る作りなら、追加の作業はない。表示だけ確認する。

## 確認すること

- カメラを選ぶ：6枚目のカードが出る。裏返すと作例（仮の色）が出る。未購入なら「詳しく見る」。
- 購入（StoreKit Configuration）：RAINY 400 を買う → 青緑の袋を破る → 使えるようになる。広告が消える。
- 4台セット：RAINY 400 だけ持っている状態でセットのボタンが出る。セットを買っても RAINY 400 は開かない（すでに持っていれば関係ない）。袋とお祝いの画面に出るのは4台だけ。
- 購入を復元：RAINY 400 が戻る。
- 撮影画面：青緑のテーマ、カメラ名の書体。
- 撮った写真：シミュレータのダミー画像で、青緑に寄った低彩度・黒の浮いた色になる。`tools/looks/looks_preview.png` の RAINY 400 と同じ傾向か。
- 封筒・アルバムのメモ欄・ホームのカメラで、名前と色が正しい。

## App Store Connect（あとで手で行う）

- アプリ内課金に `<bundle id>.camera.rainy400`（非消耗型、$0.99 相当）を作り、審査用のスクリーンショットを付ける。
