#!/bin/bash
# 부마 발명교육센터 — 로컬 서버로 열기 (인터넷 불필요)
cd "$(dirname "$0")" || exit 1

PORT=8123
while lsof -i :$PORT >/dev/null 2>&1; do PORT=$((PORT+1)); done
URL="http://localhost:$PORT/index.html"

if command -v open >/dev/null 2>&1;      then OPEN=open
elif command -v xdg-open >/dev/null 2>&1; then OPEN=xdg-open
else OPEN=""; fi

echo ""
echo "  ============================================"
echo "   부마 발명교육센터"
echo "  ============================================"
echo ""
echo "   주소 : $URL"
echo "   * 인터넷 연결은 필요하지 않습니다."
echo "   * 브라우저가 카메라를 물으면 [허용]을 눌러 주세요."
echo "   * 이 창에서 Ctrl+C 를 누르면 종료됩니다."
echo ""

[ -n "$OPEN" ] && ( sleep 1; "$OPEN" "$URL" ) &

if command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT" --bind 127.0.0.1
elif command -v python >/dev/null 2>&1; then
  exec python -m SimpleHTTPServer "$PORT"
elif command -v php >/dev/null 2>&1; then
  exec php -S "127.0.0.1:$PORT"
else
  echo "  python3 이 없어 서버를 띄우지 못했습니다."
  echo "  index.html 을 크롬으로 직접 열어도 동일하게 작동합니다."
  read -r -p "  엔터를 누르면 닫힙니다 " _
fi
