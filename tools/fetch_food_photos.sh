#!/bin/bash
# ルーベン美食ガイド: 料理・ショーケース実写の取得スクリプト
# 前提: ネットワークが lh3.googleusercontent.com に到達できる環境で実行すること
#       (Claude Code のセッションはネットワークポリシー「すべて許可」で作成する)
# 使い方: MAPS_KEY=<GoogleMapsAPIキー> bash tools/fetch_food_photos.sh
# 各店の候補写真を img_food/<店>_<n>.jpg に保存する。
# その後、料理/ショーケースが写った1枚を目視選定し img/<店>.jpg に採用すること。
set -e
[ -z "$MAPS_KEY" ] && { echo "MAPS_KEY 環境変数にAPIキーを設定してください"; exit 1; }
mkdir -p img_food
python3 - "$MAPS_KEY" <<'PY'
import json, sys, urllib.request, subprocess
KEY = sys.argv[1]
data = json.load(open("leuven_places.json"))
for name, v in data.items():
    for i, ph in enumerate(v.get("photo_names", [])[:5]):
        url = f"https://places.googleapis.com/v1/{ph}/media?maxWidthPx=640&key={KEY}"
        try:
            subprocess.run(["curl","-sSL","--max-time","40","-H","Referer: https://claude.ai/",
                            "-o",f"img_food/{name}_{i}.jpg",url],check=True)
            print(name, i, "OK")
        except Exception as e:
            print(name, i, "FAIL", e)
PY
echo "完了。img_food/ の候補から料理・ショーケースの1枚を選び img/ に採用してください。"
