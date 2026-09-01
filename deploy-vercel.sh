#!/bin/bash
# UXUI 온보딩 허브 → Vercel 프로덕션 재배포 (직접 업로드 방식)
# 사용법: VERCEL_TOKEN=xxx ./deploy-vercel.sh
set -e
T="${VERCEL_TOKEN:?VERCEL_TOKEN 환경변수 필요}"
TEAM="team_ifvJfsDPUNN0wJPkRuiaws5r"   # uxui-team1
cd "$(dirname "$0")"
SHA=$(shasum index.html | awk '{print $1}')
SIZE=$(wc -c < index.html)
curl -s -X POST "https://api.vercel.com/v2/files?teamId=$TEAM" -H "Authorization: Bearer $T" \
  -H "Content-Type: application/octet-stream" -H "x-vercel-digest: $SHA" --data-binary @index.html >/dev/null
curl -s -X POST "https://api.vercel.com/v13/deployments?teamId=$TEAM" -H "Authorization: Bearer $T" \
  -H "Content-Type: application/json" -d @- <<EOF | python3 -c "import sys,json;d=json.load(sys.stdin);print('deploy:',d.get('url'),d.get('readyState'))"
{"name":"uxui-onbording-guide","target":"production","project":"uxui-onbording-guide",
 "files":[{"file":"index.html","sha":"$SHA","size":$SIZE}],
 "projectSettings":{"framework":null,"buildCommand":null,"outputDirectory":null,"installCommand":null,"devCommand":null},
 "routes":[{"src":"/(.*)","dest":"/index.html"}]}
EOF
