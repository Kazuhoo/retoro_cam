# 書体

カメラ名と日付に使う書体です。どれも Google Fonts で配布されている SIL Open Font License（OFL）の書体で、アプリに同梱できます。

| 用途 | 書体 | 入手先 |
|---|---|---|
| SUNDAY 400 | Shrikhand | https://fonts.google.com/specimen/Shrikhand |
| NOIR 1600 | Special Elite | https://fonts.google.com/specimen/Special+Elite |
| SPLASH 200 | Pacifico | https://fonts.google.com/specimen/Pacifico |
| ALBUM 100 | DM Serif Display | https://fonts.google.com/specimen/DM+Serif+Display |
| NITE 800 | Monoton | https://fonts.google.com/specimen/Monoton |
| 24EXP・残り枚数・日付など | VT323 | https://fonts.google.com/specimen/VT323 |
| 日本語の本文 | Zen Kaku Gothic New（モックアップで使用） | https://fonts.google.com/specimen/Zen+Kaku+Gothic+New |

1. 上のページから .ttf をダウンロードして、このフォルダに置く
2. Xcode のプロジェクトに追加し、Info.plist の `UIAppFonts`（Fonts provided by application）に登録する
3. 各書体の `OFL.txt` も一緒に置き、設定画面などからライセンスを見られるようにする

日本語の本文は、システム書体（ヒラギノ角ゴ）でも問題ありません。アプリのサイズを抑えたいならシステム書体を使ってください。
