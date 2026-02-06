#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
LOG_FILE="$SCRIPT_DIR/update.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# .env에서 현재 버전 확인
CURRENT_VERSION=$(grep -oP 'TERRARIA_VERSION=\K[0-9]+' "$ENV_FILE")

log "Current version: $CURRENT_VERSION"

# terraria.wiki.gg에서 최신 버전 번호 조회
# 버전은 각 자릿수가 컴포넌트 (1454=1.4.5.4, 146=1.4.6) 이므로
# 자릿수별로 분리 후 sort -V (버전 정렬) 사용
LATEST_VERSION=$(curl -sL --connect-timeout 10 --max-time 30 \
    "https://terraria.wiki.gg/wiki/Server" 2>/dev/null \
    | grep -oP 'terraria-server-\K[0-9]+(?=\.zip)' \
    | sort -u \
    | awk '{v=$1; d=""; for(i=1;i<=length(v);i++){if(i>1)d=d"."; d=d substr(v,i,1)} print v,d}' \
    | sort -k2,2 -V | tail -1 | awk '{print $1}')

# 위키 조회 실패 시 종료
if [ -z "$LATEST_VERSION" ]; then
    log "Failed to fetch latest version from wiki."
    exit 1
fi

# terraria.org에서 실제 다운로드 가능한지 검증
HTTP_STATUS=$(curl -sI -o /dev/null -w "%{http_code}" \
    "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${LATEST_VERSION}.zip" \
    --connect-timeout 10 --max-time 15 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" != "200" ]; then
    log "Wiki reports version $LATEST_VERSION but download not available (HTTP $HTTP_STATUS)."
    exit 1
fi

if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
    log "No update available."
    exit 0
fi

log "New version found: $LATEST_VERSION (current: $CURRENT_VERSION)"

# .env 갱신 (docker-compose.yml이 참조)
sed -i "s/TERRARIA_VERSION=.*/TERRARIA_VERSION=$LATEST_VERSION/" "$ENV_FILE"

# Docker 이미지 리빌드
log "Rebuilding Docker image..."
cd "$SCRIPT_DIR"
docker compose build --no-cache

# 컨테이너 재시작
log "Restarting server..."
docker compose down
docker compose up -d

log "Server updated to version $LATEST_VERSION and restarted successfully."
