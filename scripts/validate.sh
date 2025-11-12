#!/bin/bash

# Script de validare și testare pentru RTSP Viewer Project
# Autor: Vladuceanu Tudor

set -e

# Culori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurare
JETSON_IP="${JETSON_IP:-192.168.1.100}"
MEDIAMTX_HOST="${MEDIAMTX_HOST:-localhost}"
RTSP_PORT="8554"
WEBRTC_PORT="8889"
HLS_PORT="8888"
REACT_PORT="3000"

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     RTSP Viewer - Validation & Test Script       ║${NC}"
echo -e "${BLUE}║            Vladuceanu Tudor                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Funcție pentru check
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name găsit: $(command -v $cmd)"
        return 0
    else
        echo -e "${RED}✗${NC} $name NU este instalat"
        return 1
    fi
}

# Funcție pentru check port
check_port() {
    local port=$1
    local service=$2
    
    if netstat -tuln 2>/dev/null | grep -q ":$port " || \
       ss -tuln 2>/dev/null | grep -q ":$port " || \
       lsof -i ":$port" 2>/dev/null | grep -q "LISTEN"; then
        echo -e "${GREEN}✓${NC} Port $port ($service) este DESCHIS"
        return 0
    else
        echo -e "${RED}✗${NC} Port $port ($service) NU este deschis"
        return 1
    fi
}

# Funcție pentru test RTSP
test_rtsp() {
    local url=$1
    echo -ne "${YELLOW}⏳${NC} Testare RTSP: $url ... "
    
    if timeout 5 ffprobe -v error -rtsp_transport tcp "$url" &> /dev/null; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# Funcție pentru test HTTP
test_http() {
    local url=$1
    local name=$2
    echo -ne "${YELLOW}⏳${NC} Testare HTTP ($name): $url ... "
    
    if timeout 5 curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|302"; then
        echo -e "${GREEN}✓ OK${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# ==================== PARTEA 1: Verificare Dependențe ====================
echo -e "\n${BLUE}═══ PARTEA 1: Verificare Dependențe ═══${NC}\n"

DEPS_OK=true

check_command "docker" "Docker" || DEPS_OK=false
check_command "docker-compose" "Docker Compose" || DEPS_OK=false
check_command "node" "Node.js" || DEPS_OK=false
check_command "npm" "npm" || DEPS_OK=false

echo ""
echo "Dependențe opționale:"
check_command "ffmpeg" "FFmpeg"
check_command "ffprobe" "FFprobe"
check_command "python3" "Python 3"
check_command "curl" "cURL"

if [ "$DEPS_OK" = false ]; then
    echo -e "\n${RED}⚠️  ATENȚIE: Unele dependențe esențiale lipsesc!${NC}"
    echo "Instalează-le înainte de a continua."
    exit 1
fi

# ==================== PARTEA 2: Verificare Configurație ====================
echo -e "\n${BLUE}═══ PARTEA 2: Verificare Configurație ═══${NC}\n"

CONFIG_OK=true

# Check .env
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} Fișier .env găsit"
    source .env
    echo "   JETSON_IP: $JETSON_IP"
    echo "   MEDIAMTX_HOST: $MEDIAMTX_HOST"
else
    echo -e "${RED}✗${NC} Fișier .env NU a fost găsit"
    CONFIG_OK=false
fi

# Check mediamtx.yml
if [ -f "mediamtx/mediamtx.yml" ]; then
    echo -e "${GREEN}✓${NC} Config MediaMTX găsit: mediamtx/mediamtx.yml"
    
    # Verifică dacă IP-ul Jetson este setat corect
    if grep -q "source: rtsp://$JETSON_IP" mediamtx/mediamtx.yml; then
        echo -e "${GREEN}✓${NC} IP Jetson configurat corect în mediamtx.yml"
    else
        echo -e "${YELLOW}⚠${NC} IP Jetson poate fi diferit în mediamtx.yml"
    fi
else
    echo -e "${RED}✗${NC} Config MediaMTX NU a fost găsit"
    CONFIG_OK=false
fi

# Check docker-compose.yml
if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}✓${NC} Docker Compose config găsit"
else
    echo -e "${RED}✗${NC} docker-compose.yml NU a fost găsit"
    CONFIG_OK=false
fi

# Check React package.json
if [ -f "react-viewer/package.json" ]; then
    echo -e "${GREEN}✓${NC} React package.json găsit"
else
    echo -e "${RED}✗${NC} React package.json NU a fost găsit"
    CONFIG_OK=false
fi

if [ "$CONFIG_OK" = false ]; then
    echo -e "\n${RED}⚠️  ATENȚIE: Configurația nu este completă!${NC}"
    exit 1
fi

# ==================== PARTEA 3: Test Conectivitate Rețea ====================
echo -e "\n${BLUE}═══ PARTEA 3: Test Conectivitate Rețea ═══${NC}\n"

echo "Testare conexiune la Jetson ($JETSON_IP)..."
if ping -c 3 -W 2 "$JETSON_IP" &> /dev/null; then
    echo -e "${GREEN}✓${NC} Jetson accesibil la $JETSON_IP"
else
    echo -e "${YELLOW}⚠${NC} Jetson NU răspunde la ping (poate fi blocat de firewall)"
fi

echo ""
echo "Testare localhost..."
if ping -c 2 -W 1 localhost &> /dev/null; then
    echo -e "${GREEN}✓${NC} Localhost accesibil"
else
    echo -e "${RED}✗${NC} Probleme cu localhost!"
fi

# ==================== PARTEA 4: Test Servicii Active ====================
echo -e "\n${BLUE}═══ PARTEA 4: Verificare Servicii Active ═══${NC}\n"

SERVICES_RUNNING=false

# Check Docker containers
if docker-compose ps 2>/dev/null | grep -q "Up"; then
    echo -e "${GREEN}✓${NC} Docker Compose servicii rulează"
    SERVICES_RUNNING=true
    docker-compose ps
else
    echo -e "${YELLOW}⚠${NC} Docker Compose servicii NU rulează"
    echo "   Pornește cu: docker-compose up -d"
fi

echo ""
echo "Verificare porturi deschise..."
check_port "$RTSP_PORT" "RTSP MediaMTX"
check_port "$WEBRTC_PORT" "WebRTC MediaMTX"
check_port "$HLS_PORT" "HLS MediaMTX"
check_port "$REACT_PORT" "React App"

# ==================== PARTEA 5: Test Stream RTSP ====================
echo -e "\n${BLUE}═══ PARTEA 5: Test Stream RTSP ═══${NC}\n"

if command -v ffprobe &> /dev/null; then
    echo "Testare stream de la Jetson..."
    test_rtsp "rtsp://$JETSON_IP:$RTSP_PORT/video360"
    
    if [ "$SERVICES_RUNNING" = true ]; then
        echo ""
        echo "Testare stream prin MediaMTX..."
        test_rtsp "rtsp://$MEDIAMTX_HOST:$RTSP_PORT/jetson360"
    fi
else
    echo -e "${YELLOW}⚠${NC} FFprobe nu este instalat - skip test RTSP"
fi

# ==================== PARTEA 6: Test Endpoints HTTP ====================
echo -e "\n${BLUE}═══ PARTEA 6: Test Endpoints HTTP ═══${NC}\n"

if [ "$SERVICES_RUNNING" = true ]; then
    test_http "http://$MEDIAMTX_HOST:$HLS_PORT/jetson360/index.m3u8" "HLS Manifest"
    test_http "http://$MEDIAMTX_HOST:9997/v3/config/get" "MediaMTX API"
    test_http "http://$MEDIAMTX_HOST:$REACT_PORT" "React App"
else
    echo -e "${YELLOW}⚠${NC} Servicii nu rulează - skip test HTTP"
fi

# ==================== PARTEA 7: Raport Final ====================
echo -e "\n${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              RAPORT FINAL VALIDARE                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}✓${NC} Dependențe verificate"
echo -e "${GREEN}✓${NC} Configurație validată"

if [ "$SERVICES_RUNNING" = true ]; then
    echo -e "${GREEN}✓${NC} Servicii active"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}     SISTEM FUNCȚIONAL! 🎉             ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Acces aplicație: http://$MEDIAMTX_HOST:$REACT_PORT"
    echo ""
    echo "Next steps:"
    echo "  1. Deschide browser la URL-ul de mai sus"
    echo "  2. Click pe 'Conectare WebRTC'"
    echo "  3. Verifică că stream-ul 360° se afișează"
    echo "  4. Testează salvarea video"
else
    echo -e "${YELLOW}⚠${NC} Servicii nu rulează"
    echo ""
    echo "Pornește serviciile cu:"
    echo "  docker-compose up -d"
    echo ""
    echo "Sau pentru dezvoltare locală:"
    echo "  ./mediamtx mediamtx/mediamtx.yml    # Terminal 1"
    echo "  cd react-viewer && npm start        # Terminal 2"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo "Pentru mai multe detalii, vezi:"
echo "  • README.md         - Documentație completă"
echo "  • QUICKSTART.md     - Ghid rapid"
echo "  • CONFIG_EXAMPLES.md - Exemple configurare"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
