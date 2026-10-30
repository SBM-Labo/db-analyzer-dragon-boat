# デプロイ手順書 ― ドラゴンボート レース分析ツール

GitHub Pages にデプロイし、**パスワード認証付き** で公開する手順を説明します。

---

## ① 暗号化(初回・パスワード変更時)

このフォルダの中で次のコマンドを実行すると、`index.html` がパスワード暗号化されます(中身は AES-256 で保護され、正しいパスワードを知っている人しか中身を見られません)。

### Windows の場合

PowerShell または コマンドプロンプトでこのフォルダを開いて:

```cmd
:: 1) Node.js が未インストールなら https://nodejs.org/ja から LTS版をインストール

:: 2) staticrypt をインストール(初回のみ)
npm install -g staticrypt

:: 3) 暗号化を実行(パスワードはお好みで決めてください、例: dragon2026)
encrypt.bat dragon2026
```

### macOS / Linux の場合

```bash
# 1) Node.js が未インストールなら https://nodejs.org/ja から
brew install node  # macOS の場合
# Linux: sudo apt install nodejs npm

# 2) staticrypt をインストール(初回のみ)
sudo npm install -g staticrypt

# 3) 暗号化を実行
chmod +x encrypt.sh
./encrypt.sh dragon2026
```

実行後の状態:
- `index.html` ― 暗号化済み(これを公開する)
- `index.html.unencrypted` ― 元の平文(公開しない、ローカルバックアップとして保管)

**パスワードを忘れたら復旧不可** なので、複数の場所(委員会内で共有しているNotion等)に書き留めてください。

---

## ② GitHub Pages にデプロイ

### 手順1. GitHubアカウント作成 (5分・初回のみ)

1. https://github.com を開く
2. 「Sign up」から無料アカウント作成
3. メール認証を完了

### 手順2. リポジトリ作成 (3分)

1. GitHubトップ右上の「+」→「New repository」
2. リポジトリ名: `db-analyzer` (お好みで)
3. **Public** を選択(中身は暗号化されているのでPublicでOK、Privateにすると無料ではPages使えません)
4. 「Add a README file」にチェック
5. 「Create repository」をクリック

### 手順3. ファイルをアップロード (5分)

1. リポジトリ画面で「Add file」→「Upload files」
2. **`index.html.unencrypted` 以外** のすべてのファイル/フォルダをドラッグ&ドロップ
   - `index.html` ← 暗号化されたもの
   - `manifest.json`
   - `race_results.json`
   - `data/` フォルダ
   - `scripts/` フォルダ
   - `generate_manifest.py`
   - `README.md`
   - `deploy_guide.md`
3. 下の「Commit changes」をクリック

⚠️ **絶対にやってはいけないこと**: `index.html.unencrypted`(平文)をアップロードしないでください。これをアップロードすると、URLを知っている人がパスワードなしで中身を読めてしまいます。

### 手順4. GitHub Pagesを有効化 (2分)

1. リポジトリ画面 → 上部「Settings」タブ
2. 左サイドバー「Pages」をクリック
3. 「Branch」セクションで `main` を選択、フォルダは `/ (root)` のまま「Save」
4. 1〜2分待つと、ページ上部に公開URLが表示される

例: `https://<あなたのGitHubID>.github.io/db-analyzer/`

### 手順5. 動作確認

公開URLにアクセス。日本語の「パスワードを入力してください」画面が出れば成功。パスワードを入力すると本体ツールが開きます。

---

## ③ データを更新するとき

新しい大会データの追加や、index.html の機能改修を行ったあと:

```bash
# 1) data/ に新しいCSV/xlsxを追加し、manifest を再生成
python3 generate_manifest.py

# 2) レース結果PDFを解析(該当する場合)
python3 scripts/parse_race_results.py 新しい結果.pdf -o race_results.json

# 3) index.html.unencrypted を編集(機能改修時のみ)

# 4) 暗号化を実行
./encrypt.sh dragon2026     # Linux/Mac
# encrypt.bat dragon2026    # Windows

# 5) GitHub にプッシュ(変更ファイルをUpload filesで再アップロード)
```

---

## ④ パスワードを変更するとき

新しいパスワードで再暗号化するだけです:

```bash
./encrypt.sh 新しいパスワード
```

このとき:
- `index.html.unencrypted` から再暗号化されるので、原本は守られる
- GitHub に新しい `index.html` をアップロードすれば、即座に新パスワードに切り替わる
- 既にログイン済みのユーザは「ログインを記憶」のクッキー期限切れ後に再認証が必要

---

## 注意事項とセキュリティの限界

- **暗号化されているのはHTMLツール本体のみ** です。`data/*.csv` や `manifest.json`、`race_results.json` のURLを直接知っている人は、これらのデータは取得できます。これらは「公開しても問題ないGPS記録」という前提です。
- **十分な強度のパスワードを使ってください**。staticryptは1秒に何万回ものパスワード試行に耐えるよう設計されていますが、`123456` のような弱いパスワードはブルートフォース攻撃で破られる可能性があります。**最低でも10文字以上、英数字+記号混在** を推奨します。
- **完全に部外者を排除したい場合**は、Cloudflare Pages + Cloudflare Access(無料・最大50ユーザ・メール認証付き)を検討してください。

---

## 簡易動作確認用

公開URLが `https://example.github.io/db-analyzer/` だとして:

- トップ: `https://example.github.io/db-analyzer/` → パスワード画面
- チーム別URL: `https://example.github.io/db-analyzer/?team=魚橋水神龍会&races=data/2025-11-02/R24_オープン決勝_02_魚橋水神龍会.csv`
  - チーム別リンクでもパスワードが必要(1度ログインすれば30日間記憶)
