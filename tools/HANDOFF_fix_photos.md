# 引き継ぎ: ルーベンレストランガイドの店舗写真 修正タスク

対象リポジトリ: `HNishimura0504/test`（公開）
対象ブランチ: `claude/restaurant-database-expansion-ihrmop`（PR #2）
**この作業はネットワーク「すべて許可」セッションでのみ実行可能**（料理写真の実データが
`lh3.googleusercontent.com` から配信され、制限セッションでは403で取得できないため）。

---

## そのまま貼れる引き継ぎプロンプト

> ルーベンレストランガイド（`HNishimura0504/test`, ブランチ `claude/restaurant-database-expansion-ihrmop`）の
> 店舗写真を「その店の料理または店内の実写のみ」の方針に合わせて修正する。着手前に GitHub ai-memory の
> `AI_memory.md` と `topics/restaurant_guide_playbook.md` を読む。
>
> **前提確認**: このタスクは `lh3.googleusercontent.com` への接続が必要。
> `curl -sS -o /dev/null -w '%{http_code}\n' https://lh3.googleusercontent.com/ ` 等で到達可（=全許可セッション）を
> 確認してから進める。403等で不通なら「すべて許可」セッションで作り直す（下記セットアップ参照）。
>
> **修正対象**（現状の写真が基準違反）:
> - 必須: `domus`（現状=ビールグラス単体）／`stella`（現状=ビール・ワイングラス単体）。**飲み物単体は不可** →
>   Domus は店内 or 郷土料理、Stella は醸造所の設備/店内 or 見学の様子に差し替える。
> - 要判断: `oudemarkt`（広場テラスの外観）／`muntstraat`（レストラン通りの外観）。店内/料理に替えるかは
>   ユーザーに確認（この2つは単一店でなく「エリア」なので外観許容の判断もあり得る）。
>
> **手順**:
> 1. Maps APIキー（`AI_memory.md` §4）を使用。`leuven_places.json` の対象店 `photo_names` から候補取得:
>    `MAPS_KEY=<キー> bash tools/fetch_food_photos.sh`（`img_food/<slug>_<n>.jpg` に保存）。候補に良い
>    料理/店内が無ければ `GET https://places.googleapis.com/v1/places/<place_id>?fields=photos`
>    （ヘッダ `X-Goog-Api-Key: <キー>`, `Referer: https://claude.ai/`）で6枚目以降を取得。
> 2. 対象店ごとに **料理または店内**の1枚を目視選定して `img/<slug>.jpg` に上書き（飲み物単体・店構え/外観は不可）。
> 3. 念のため全36枚を目視で再監査し、drinks-only / 外観 / ストック画像があれば同様に差し替え。
> 4. PDF再生成: `chromium --headless --no-sandbox --no-pdf-header-footer --print-to-pdf="ルーベン美食ガイド_スマホ版.pdf" leuven.html`
>    （`chromium` が無ければ `/opt/pw-browsers/chromium*/chrome-linux/chrome`）。
> 5. 公開リポジトリなので `grep -rn AIzaSy .` で**キー混入ゼロ**を確認。`img_food/` はコミットしない。
> 6. `git add -A && git commit && git push origin claude/restaurant-database-expansion-ihrmop`（PR #2 が更新される）。
> 7. ai-memory の `worklog.md` に修正内容を記録。
>
> **納品前チェック**: 全カードの写真が料理/店内か？ 飲み物単体・店構えの混入ゼロか？ PDFに反映済みか？ キー混入ゼロか？

---

## 実行可能セッションのセットアップ（Claude Code on the web）

- 新しい環境/セッションを作成する際、**ネットワークアクセスを「すべて許可（Allow all / 制限なし）」**に設定する。
  現行の制限（許可リスト）ポリシーでは `lh3.googleusercontent.com` が遮断され写真を取得できない。
  ネットワークポリシーは環境作成時に選ぶ（参照: https://code.claude.com/docs/en/claude-code-on-the-web ）。
- リポジトリスコープに **`HNishimura0504/test`** を含める（写真の差し替え先）。キー参照のため
  **`HNishimura0504/ai-memory`** も含めるか、キーを直接貼る。
- 上記プロンプトを貼って実行。作業ブランチは `claude/restaurant-database-expansion-ihrmop`。
- 参考: 全36店の初回写真アップグレードは、この全許可セッション方式で実際に完了実績あり（commit fa92a04）。
  今回は残りの基準違反（domus / stella ほか）を同じ方式で直すだけ。
