# 引き継ぎ: ルーベンレストランガイドの店舗写真 修正タスク

対象リポジトリ: HNishimura0504/test（公開）／対象ブランチ: claude/restaurant-database-expansion-ihrmop（PR #2）
この作業はネットワーク「すべて許可」セッションでのみ実行可能（料理写真の実データが
lh3.googleusercontent.com から配信され、制限セッションでは403で取得できないため）。

---

## コピペ用プロンプト（このコードブロックをそのまま貼る）

```
ルーベンレストランガイド（GitHub: HNishimura0504/test、ブランチ claude/restaurant-database-expansion-ihrmop、PR #2）の店舗写真を「その店の料理または店内の実写のみ」の方針に直してください。

前提:
- 着手前に ai-memory の AI_memory.md と topics/restaurant_guide_playbook.md を読む。
- この作業は lh3.googleusercontent.com への接続が必要。まず次で到達可（=ネットワーク全許可セッション）を確認する:
  curl -sS -o /dev/null -w '%{http_code}\n' https://lh3.googleusercontent.com/
  403 等で不通ならこのタスクは実行できないので中止して報告する。

修正対象（現状の写真が基準違反）:
- 必須: domus（現状=ビールグラス単体）→ 店内 または 郷土料理の写真へ差し替え。
- 必須: stella（現状=ビール・ワイングラス単体）→ 醸造所の設備/店内 または 見学の様子へ差し替え。
  ※飲み物単体は不可。
- 要判断: oudemarkt（広場テラスの外観）と muntstraat（レストラン通りの外観）。
  店内/料理に替えるか外観のまま許容するかはユーザーに確認する（この2つは単一店でなく「エリア」）。

手順:
1. Maps APIキー（AI_memory.md の §4）を使う。対象店の候補写真を取得:
   MAPS_KEY=<キー> bash tools/fetch_food_photos.sh
   （img_food/<slug>_<n>.jpg に保存される）。候補に良い料理/店内が無ければ、
   curl にヘッダ "X-Goog-Api-Key: <キー>" と "Referer: https://claude.ai/" を付けて
   GET https://places.googleapis.com/v1/places/<place_id>?fields=photos で6枚目以降を取得する
   （place_id は leuven_places.json にある）。
2. 対象店ごとに、料理または店内が写った1枚を目視で選び img/<slug>.jpg に上書きする。
   飲み物単体・店構え/外観は採用しない。
3. 念のため img/ の全36枚を目視で再監査し、飲み物単体/外観/ストック画像があれば同様に差し替える。
4. PDFを再生成する:
   chromium --headless --no-sandbox --no-pdf-header-footer --print-to-pdf="ルーベン美食ガイド_スマホ版.pdf" leuven.html
   （chromium が無ければ /opt/pw-browsers/chromium*/chrome-linux/chrome を使う）。
5. 公開リポジトリなので grep -rn AIzaSy . でAPIキーが混入していないことを確認。img_food/ はコミットしない。
6. git add -A && git commit && git push origin claude/restaurant-database-expansion-ihrmop
   （PR #2 が更新される）。
7. ai-memory の worklog.md に修正内容を記録する。

納品前チェック: 全カードの写真が料理/店内か、飲み物単体・店構えの混入がゼロか、PDFに反映されたか、キー混入がゼロか。
```

---

## 実行可能セッションのセットアップ（Claude Code on the web）

- 新しい環境/セッションを作成する際、ネットワークアクセスを「すべて許可（制限なし）」に設定する。
  現行の許可リスト方式では lh3.googleusercontent.com が遮断され写真を取得できない。
  ネットワークポリシーは環境作成時に選ぶ（参照: https://code.claude.com/docs/en/claude-code-on-the-web ）。
- リポジトリスコープに HNishimura0504/test を含める（差し替え先）。キー参照のため ai-memory も含めるか、キーを直接貼る。
- 上記コードブロックのプロンプトを貼って実行。作業ブランチは claude/restaurant-database-expansion-ihrmop。
- 参考: 全36店の初回写真化はこの全許可セッション方式で完了実績あり（commit fa92a04）。
