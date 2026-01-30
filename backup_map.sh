#!/bin/bash

# 스크립트가 있는 디렉터리(맵 폴더)로 이동
cd "$(dirname "$0")"

# 변경 사항이 있는지 확인
if [[ -n $(git status -s) ]]; then
    echo "[$(date)] Changes detected. Starting backup..." >> backup.log

    # Git 명령 실행
    git add .
    git commit -m "Auto Backup: $(date '+%Y-%m-%d %H:%M:%S')"

    # 충돌 방지 및 푸시
    git pull --rebase origin main
    git push origin main

else
    echo "[$(date)] No changes detected." >> backup.log
fi
