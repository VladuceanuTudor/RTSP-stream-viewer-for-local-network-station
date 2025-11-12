# Makefile pentru RTSP 360° Viewer Project
# Autor: Vladuceanu Tudor

.PHONY: help install start stop restart logs validate clean build dev

# Variabile
COMPOSE = docker-compose
SCRIPTS = scripts

# Default target
help:
	@echo "╔═══════════════════════════════════════════════════╗"
	@echo "║   RTSP 360° Viewer - Comenzi Disponibile         ║"
	@echo "╚═══════════════════════════════════════════════════╝"
	@echo ""
	@echo "  make install     - Instalează dependențe"
	@echo "  make start       - Pornește serviciile (Docker)"
	@echo "  make stop        - Oprește serviciile"
	@echo "  make restart     - Restartează serviciile"
	@echo "  make logs        - Afișează log-uri live"
	@echo "  make validate    - Validează setup-ul"
	@echo "  make dev         - Pornește dezvoltare locală"
	@echo "  make build       - Build pentru producție"
	@echo "  make clean       - Curăță fișiere temporare"
	@echo ""
	@echo "  make record      - Pornește înregistrare FFmpeg"
	@echo "  make record-py   - Pornește înregistrare Python"
	@echo ""

# Instalare dependențe
install:
	@echo "📦 Instalare dependențe React..."
	cd react-viewer && npm install --legacy-peer-deps
	@echo "✅ Dependențe instalate!"

# Pornește serviciile Docker
start:
	@echo "🚀 Pornire servicii Docker..."
	$(COMPOSE) up -d
	@echo ""
	@echo "✅ Servicii pornite!"
	@echo "Acces: http://localhost:3000"
	@echo ""
	@echo "Pentru log-uri live: make logs"

# Oprește serviciile
stop:
	@echo "⏸️  Oprire servicii..."
	$(COMPOSE) down
	@echo "✅ Servicii oprite!"

# Restartează serviciile
restart: stop start

# Log-uri live
logs:
	@echo "📜 Log-uri live (Ctrl+C pentru stop)..."
	$(COMPOSE) logs -f

# Validare setup
validate:
	@echo "🔍 Validare setup..."
	@bash $(SCRIPTS)/validate.sh

# Dezvoltare locală (fără Docker)
dev:
	@echo "💻 Pornire dezvoltare locală..."
	@echo ""
	@echo "1️⃣  Terminal 1 - MediaMTX:"
	@echo "   ./mediamtx mediamtx/mediamtx.yml"
	@echo ""
	@echo "2️⃣  Terminal 2 - React App:"
	@echo "   cd react-viewer && npm start"
	@echo ""

# Build pentru producție
build:
	@echo "🏗️  Build React pentru producție..."
	cd react-viewer && npm run build
	@echo "✅ Build completat în react-viewer/build/"

# Build Docker images
build-docker:
	@echo "🐳 Build Docker images..."
	$(COMPOSE) build
	@echo "✅ Docker images build completat!"

# Curățare
clean:
	@echo "🧹 Curățare fișiere temporare..."
	rm -rf react-viewer/node_modules
	rm -rf react-viewer/build
	rm -rf recordings/*
	$(COMPOSE) down -v
	@echo "✅ Curățare completă!"

# Înregistrare FFmpeg
record:
	@echo "🎥 Pornire înregistrare FFmpeg..."
	@bash $(SCRIPTS)/record_stream.sh

# Înregistrare Python
record-py:
	@echo "🎥 Pornire înregistrare Python..."
	@python3 $(SCRIPTS)/record_stream.py --host localhost --preview

# Status servicii
status:
	@echo "📊 Status servicii Docker:"
	@$(COMPOSE) ps

# Test conexiuni
test:
	@echo "🧪 Testare conexiuni..."
	@echo ""
	@echo "Test MediaMTX API:"
	@curl -s http://localhost:9997/v3/config/get | head -n 5 || echo "❌ MediaMTX API nu răspunde"
	@echo ""
	@echo "Test React App:"
	@curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:3000 || echo "❌ React App nu răspunde"
	@echo ""
	@echo "Test HLS:"
	@curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8888/jetson360/index.m3u8 || echo "❌ HLS nu răspunde"

# Quick restart pentru debug
quick-restart:
	@echo "⚡ Quick restart..."
	$(COMPOSE) restart mediamtx
	@sleep 2
	@echo "✅ MediaMTX restartat!"

# Update dependencies
update:
	@echo "🔄 Update dependențe React..."
	cd react-viewer && npm update
	@echo "✅ Dependențe actualizate!"

# Backup configurație
backup:
	@echo "💾 Backup configurație..."
	@mkdir -p backups
	@tar -czf backups/config-backup-$$(date +%Y%m%d-%H%M%S).tar.gz \
		.env mediamtx/mediamtx.yml docker-compose.yml
	@echo "✅ Backup creat în backups/"

# Setup pentru prima dată
setup: install
	@echo "🔧 Setup inițial..."
	@echo ""
	@echo "1. Verifică și editează .env cu IP-ul Jetson-ului"
	@echo "2. Verifică mediamtx/mediamtx.yml"
	@echo "3. Rulează: make validate"
	@echo "4. Pornește: make start"
	@echo ""
