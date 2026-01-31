#!/bin/bash
set -e

WORLD_FILE="/data/world1.wld"

if [ ! -f "$WORLD_FILE" ]; then
    echo "Error: World file not found at $WORLD_FILE!"
    echo "Server execution aborted to prevent accidental overwrite."
    exit 1
fi

echo "World file found. Starting Terraria Server..."
# Execute the server command without -autocreate
exec box64 ./TerrariaServer.bin.x86_64 -port 7777 -worldpath /data -world "$WORLD_FILE"
