# 🏰 OCI Terraria Server (ARM64 / Box64)

Oracle Cloud (ARM64/Ubuntu 24.04) 환경에서 **Box64**를 이용해 구동하는 테라리아 바닐라(Vanilla) 서버입니다.
x86_64 기반의 공식 서버 파일을 ARM 리눅스에서 네이티브에 준하는 성능으로 실행합니다.

## 📂 디렉토리 구조
\`\`\`text
.
├── Dockerfile             # Ubuntu 24.04 + Box64 + Terraria Server 설정
├── docker-compose.yml     # 컨테이너 실행 및 데이터 볼륨 연결
├── world_data/            # [Volume] 맵 파일 저장소 (호스트 공유)
└── README.md              # 설명서
\`\`\`

## 🚀 서버 실행 및 종료

### 실행 (Build & Run)
\`\`\`bash
docker compose up -d --build
\`\`\`

### 로그 확인 (초기 맵 생성 확인)
\`\`\`bash
docker compose logs -f
\`\`\`

### 종료 (Stop)
\`\`\`bash
docker compose down
\`\`\`

## 🗺️ 맵 파일 업로드 (Windows → Server)

서버가 생성한 맵이 마음에 들지 않거나, PC에서 작업한 맵을 올리는 방법입니다.

### 1. (서버) 권한 변경
도커가 생성한 폴더는 \`root\` 권한이므로, 파일을 덮어쓰기 위해 권한을 가져옵니다.
\`\`\`bash
sudo chown -R ubuntu:ubuntu ~/game_servers/oci_terraria_server/world_data
\`\`\`

### 2. (Windows PowerShell) 파일 전송
**주의:** 서버는 \`world1.wld\` 파일만 인식합니다. 전송 시 이름을 변경해주세요.

\`\`\`powershell
# 예시: 내 PC의 'Winter.wld'를 서버의 'world1.wld'로 덮어쓰기
scp "C:\Users\User\Documents\My Games\Terraria\Worlds\Winter.wld" ubuntu@yeonjae.kr:/home/ubuntu/game_servers/oci_terraria_server/world_data/world1.wld
\`\`\`

## 🎮 콘솔 명령어 (Server Console)
서버가 켜진 상태에서 저장(save), 종료(exit) 등의 명령어를 입력하려면:

\`\`\`bash
docker attach terraria_box64
\`\`\`

> **⚠️ 주의:** 나갈 때는 \`Ctrl + C\`를 누르지 마세요! (서버 꺼짐)
> **\`Ctrl + P\`**, **\`Ctrl + Q\`**를 차례대로 눌러서 나와야 합니다.
