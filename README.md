# retoro_cam

使い捨てカメラを再現した iOS カメラアプリ（仮称）。

撮った写真はその場では見られません。24枚撮り切ってカメラごと現像に出すと、3日後に写真が封筒に入って届きます。

## リポジトリの中身

| パス | 中身 |
|---|---|
| `CLAUDE.md` | Claude Code 向けの決まりごと |
| `docs/spec.md` | 仕様書（これが正） |
| `docs/mockups/` | 各画面のモックアップ（HTML） |
| `docs/reference/FilmLook.swift` | 写真の加工処理のたたき台 |
| `Resources/LUTs/` | 5台分の色味（.cube） |
| `Resources/Fonts/` | カメラ名の書体（入手方法は中の README） |
| `tools/looks/` | 色味を作り直すスクリプトと比較画像 |

## はじめに

1. Xcode でこのフォルダに iOS App（SwiftUI）のプロジェクトを作る（プロジェクト名 `RetoroCam`、iOS 17.2、横向きのみ）
2. `Resources/LUTs/*.cube` をプロジェクトに追加する
3. Claude Code で `docs/spec.md` のマイルストーン1から実装していく
