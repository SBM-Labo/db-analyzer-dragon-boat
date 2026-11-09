# data/bench.json の作り方 (フィードバックの比較用データ)

フィードバックは、同じ大会・同じ艇種 (スモール/標準艇)・同じ種別の全艇と比べて作る。そのために全レースの解析指標をツールと同じ計算で一括算出したのが `data/bench.json`。
データ (manifest.json) を追加したら作り直す。

1. 復号した index.html (平文) の `GITHUB_BASE` を `http://localhost:8765/` に置き換えて、リポジトリ直下に `_test.html` として置く
2. リポジトリ直下で `python3 -m http.server 8765` を起動
3. `node tools/gen_bench_metrics.js` (Playwright) → bench_raw.json (全艇の指標)
4. bench_raw.json に艇種 (type: クラス名か大会名に「スモール」→ small、それ以外 std) と種別 (cat: シニア/女子/混合/普及/オープン/other) を付けて `data/bench.json` の `boats` に書く
