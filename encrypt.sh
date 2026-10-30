#!/usr/bin/env bash
# ============================================================
# index.html を staticrypt でパスワード暗号化するラッパー
#
# 使い方:
#   ./encrypt.sh "<password>"
#
# 動作:
#   1. index.html を一時退避 (index.html.unencrypted)
#   2. パスワードで暗号化 → 同じ index.html を上書き
#   3. これでフォルダごとデプロイすると、トップにパスワード画面が出る
#
# 平文に戻したいとき:
#   cp index.html.unencrypted index.html
#
# 依存: staticrypt (グローバル or ローカル)
#   npm install -g staticrypt
# ============================================================
set -e
cd "$(dirname "$0")"

PASSWORD="${1:-}"
if [ -z "$PASSWORD" ]; then
  echo "使い方: $0 <password>"
  exit 1
fi

if [ ! -f index.html ]; then
  echo "index.html が見つかりません"
  exit 1
fi

# 既に暗号化済みかチェック (.unencrypted があれば再暗号化扱い)
if [ -f index.html.unencrypted ]; then
  echo "[info] 既に暗号化済みです。元のindex.htmlに戻してから再暗号化します。"
  cp index.html.unencrypted index.html
else
  cp index.html index.html.unencrypted
fi

# staticrypt 検出
if command -v staticrypt &>/dev/null; then
  STATICRYPT=staticrypt
elif [ -x ./node_modules/.bin/staticrypt ]; then
  STATICRYPT=./node_modules/.bin/staticrypt
else
  echo "staticrypt が見つかりません。インストール:"
  echo "  npm install -g staticrypt"
  echo "  または: npm install staticrypt  (このフォルダで)"
  exit 1
fi

OUT=/tmp/dba_enc_$$
mkdir -p "$OUT"

"$STATICRYPT" index.html -p "$PASSWORD" \
  --short \
  -d "$OUT" \
  --template-title "ドラゴンボート レース分析ツール" \
  --template-instructions "委員会から配布されたパスワードを入力してください" \
  --template-placeholder "パスワード" \
  --template-button "開く" \
  --template-remember "ログインを記憶 (30日間)" \
  --template-error "パスワードが違います" \
  --remember 30

cp "$OUT/index.html" index.html
rm -rf "$OUT"

echo "[ok] index.html を暗号化しました (パスワードは引数で指定したもの)"
echo "[ok] 元の平文は index.html.unencrypted に退避してあります"
echo ""
echo "次のステップ:"
echo "  - データ更新時は: index.html.unencrypted を編集 → このスクリプトを再実行"
echo "  - GitHub Pages にプッシュ or Netlify Drop でアップロード"
