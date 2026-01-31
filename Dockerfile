FROM arm64v8/ubuntu:24.04

# 필수 패키지 설치
# curl, wget, unzip 등 기본 유틸리티 설치
RUN apt-get update && apt-get install -y \
    wget unzip gnupg ca-certificates curl nano \
    && rm -rf /var/lib/apt/lists/*

# Box64 설치 (ARM에서 x86 구동)
# Ryan Fortner 공식 저장소 사용
# 키를 다운로드하여 keyring에 저장하고, sources.list에 [signed-by] 옵션을 추가합니다.
RUN mkdir -p /etc/apt/keyrings \
    && wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/keyrings/box64-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/box64-archive-keyring.gpg] https://ryanfortner.github.io/box64-debs/debian ./ " | tee /etc/apt/sources.list.d/box64.list \
    && apt-get update && apt-get install -y box64

# 테라리아 서버 다운로드 (공식 링크 사용)
WORKDIR /terraria

RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-1453.zip \
    && unzip terraria-server-1453.zip \
    && mv */Linux/* . \
    && rm -rf 1453 terraria-server-1453.zip Windows Mac \
    && chmod +x TerrariaServer.bin.x86_64

# 데이터 경로 설정
VOLUME [ "/data" ]
EXPOSE 7777

# 실행 명령어 (Box64 구동)
# -worldpath /data : 호스트와 연결된 볼륨에 맵 저장
# -autocreate 3 : Large 사이즈 (1=Small, 2=Medium, 3=Large)
CMD ["box64", "./TerrariaServer.bin.x86_64", "-port", "7777", "-worldpath", "/data", "-world", "/data/world1.wld", "-autocreate", "3"]
