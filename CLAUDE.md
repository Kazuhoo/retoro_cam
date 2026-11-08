# CLAUDE.md

使い捨てカメラを再現した iOS カメラアプリ（仮称 retoro_cam）。

## まず読むもの

- `docs/spec.md` — 仕様のすべて。**この文書が正**。書かれていないことを決める必要が出たら、実装する前に確認すること
- `docs/mockups/*.dc.html` — 各画面のモックアップ（HTML）。レイアウト・色・文言の参考。対応表は spec.md の「画面一覧」
- `docs/reference/FilmLook.swift` — 写真の加工処理のたたき台（未ビルド）
- `Resources/LUTs/*.cube` — 5台分の色味。`tools/looks/README.md` に加工の数値

## 技術

- Swift / SwiftUI、iOS 17.2 以上、iPhone のみ、**横向きのみ**
- AVFoundation（`AVCaptureEventInteraction` で音量ボタンのシャッター）
- Core Image（LUT は `CIColorCubeWithColorSpace`、sRGB）
- SwiftData、StoreKit 2、UserNotifications、Photos（追加のみ）
- Google Mobile Ads ＋ UMP（Swift Package Manager）
- サーバーなし。外部APIなし

## 作り方の決まり

- 状態管理は `@Observable` を使う。画面ごとに View と小さなモデル／ロジックを分ける
- 1ファイルを大きくしない。目安300行を超えたら分ける
- 現在時刻は直接 `Date()` を使わず、`Clock` プロトコル経由で取得する（デバッグメニューで時間を進めるため）
- 文言は日本語。`Localizable.xcstrings`（String Catalog）に入れる
- 色・書体・寸法は `Theme` などにまとめ、View に直書きしない。テーマの値は spec.md の表のとおり
- 広告ユニットIDなどの値はコードやリポジトリに書かない。`Config/Secrets.xcconfig`（gitignore対象）から読む。開発中はAdMobのテスト用IDを使う
- サードパーティのライブラリは Google Mobile Ads / UMP 以外、勝手に追加しない

## やらないこと

- 撮った直後に写真を見せる機能（コンセプトに反する）
- 画面上のシャッターボタン
- フラッシュ以外のカメラ機能（インカメラ、ズーム、露出補正、フィルター選択など）
- 途中で現像に出す機能
- 設定でシャッター音を消す機能
- spec.md にない機能の追加

## 確認のしかた

- カメラはシミュレータで動かない。カメラまわりは実機で確認する前提で、シミュレータではプレビューの代わりにダミー画像を出せるようにしておく
- 課金は StoreKit Configuration ファイル（`RetoroCam.storekit`）でテストする
- 3日の待ち時間はデバッグメニュー（DEBUG ビルドのみ）で時間を進めて確認する

## 進め方

- `docs/spec.md` の「マイルストーン」の順に、1つずつ実装する
- 作業の最初に計画を出し、確認を取ってからコードを書く
- 1マイルストーンごとにブランチを切り、動いたらコミットする
- 仕様と違う実装が必要だと分かったら、spec.md の変更案として提案する
