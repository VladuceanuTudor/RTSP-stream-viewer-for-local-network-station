#!/bin/bash

# Script pentru salvarea stream-ului RTSP folosind FFmpeg
# Autor: Vladuceanu Tudor

set -e

# Configurare
MEDIAMTX_HOST="${MEDIAMTX_HOST:-localhost}"
RTSP_PORT="${RTSP_PORT:-8554}"
STREAM_PATH="${STREAM_PATH:-jetson360}"
OUTPUT_DIR="${OUTPUT_DIR:-./recordings}"

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== RTSP Stream Recorder ===${NC}"
echo ""

# Verifică dacă FFmpeg este instalat
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}❌ FFmpeg nu este instalat!${NC}"
    echo "Instalează FFmpeg:"
    echo "  Ubuntu/Debian: sudo apt-get install ffmpeg"
    echo "  MacOS: brew install ffmpeg"
    exit 1
fi

# Creează directorul de output
mkdir -p "$OUTPUT_DIR"

# Construiește URL-ul RTSP
RTSP_URL="rtsp://${MEDIAMTX_HOST}:${RTSP_PORT}/${STREAM_PATH}"

echo -e "${YELLOW}📡 Conectare la: ${RTSP_URL}${NC}"
echo ""

# Nume fișier cu timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="${OUTPUT_DIR}/recording_360_${TIMESTAMP}.mp4"

echo -e "${GREEN}💾 Salvare în: ${OUTPUT_FILE}${NC}"
echo -e "${YELLOW}Apasă Ctrl+C pentru a opri înregistrarea${NC}"
echo ""

# Înregistrează stream-ul
# -rtsp_transport tcp: folosește TCP pentru conexiune mai stabilă
# -i: input RTSP
# -c copy: copiază codecuri fără re-encodare (mai rapid, calitate originală)
# -y: suprascrie fișierul dacă există
ffmpeg \
    -rtsp_transport tcp \
    -i "$RTSP_URL" \
    -c copy \
    -movflags +faststart \
    -y \
    "$OUTPUT_FILE"

echo ""
echo -e "${GREEN}✅ Înregistrare finalizată!${NC}"
echo -e "Fișier salvat: ${OUTPUT_FILE}"

# Afișează informații despre fișier
if [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo -e "Mărime: ${FILE_SIZE}"
fi
