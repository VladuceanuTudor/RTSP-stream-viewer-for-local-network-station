# 💻 Setup Dezvoltare Locală (Fără Docker)

Dacă preferi să rulezi proiectul fără Docker, urmează acești pași.

## Cerințe

- Node.js 18+ și npm
- FFmpeg (opțional, pentru script-uri)
- Python 3.8+ și OpenCV (opțional)

## Instalare MediaMTX

### Linux/macOS

```bash
# Descarcă ultima versiune
cd ~/Downloads
wget https://github.com/bluenviron/mediamtx/releases/download/v1.6.0/mediamtx_v1.6.0_linux_amd64.tar.gz

# Extrage
tar -xzf mediamtx_v1.6.0_linux_amd64.tar.gz

# Mută în proiect
mv mediamtx ~/rtsp-viewer-project/
```

### Windows

1. Descarcă: https://github.com/bluenviron/mediamtx/releases/download/v1.6.0/mediamtx_v1.6.0_windows_amd64.zip
2. Extrage în folder proiect
3. Redenumește `mediamtx.exe`

## Configurare și Pornire

### 1. Pornește MediaMTX

**Linux/macOS:**
```bash
cd rtsp-viewer-project
./mediamtx mediamtx/mediamtx.yml
```

**Windows:**
```cmd
cd rtsp-viewer-project
mediamtx.exe mediamtx\mediamtx.yml
```

Ar trebui să vezi:
```
INFO [RTSP] listener opened on :8554 (TCP), :8000 (UDP/RTP), :8001 (UDP/RTCP)
INFO [HLS] listener opened on :8888
INFO [WebRTC] listener opened on :8889
```

### 2. Pornește React App

**Terminal nou:**

```bash
cd rtsp-viewer-project/react-viewer

# Prima dată: instalează dependențe
npm install --legacy-peer-deps

# Pornește development server
npm start
```

Browser-ul se va deschide automat la: http://localhost:3000

## Verificare Setup

### Test MediaMTX

```bash
# Verifică că MediaMTX ascultă pe porturi
netstat -tuln | grep -E '8554|8888|8889'

# Testează cu FFmpeg (dacă Jetson trimite deja)
ffprobe rtsp://localhost:8554/jetson360
```

### Test React App

1. Deschide http://localhost:3000
2. Ar trebui să vezi interfața aplicației
3. Dacă Jetson nu trimite încă, vei vedea "Niciun stream conectat"

## Dezvoltare

### Hot Reload

React App folosește **hot reload** - modificările în cod se aplică automat în browser.

### Structura Fișierelor

```
react-viewer/src/
├── App.js                    # Modifică aici logica principală
├── components/
│   ├── Video360Viewer.js    # Modifică vizualizarea 360°
│   ├── StreamController.js  # Modifică controalele conexiune
│   └── RecordingPanel.js    # Modifică funcționalitatea de salvare
└── *.css                     # Modifică stilurile
```

### Debug

**Browser DevTools:**
- Apasă `F12` pentru Console
- Vezi erori WebRTC în Console
- Network tab pentru cereri HTTP

**MediaMTX Logs:**
- Vezi terminalul unde rulează MediaMTX
- Log level se poate schimba în `mediamtx.yml`

## Build pentru Producție

```bash
cd react-viewer

# Creează build optimizat
npm run build

# Fișierele vor fi în react-viewer/build/
```

### Servire Build cu Nginx

```bash
# Instalează nginx
sudo apt-get install nginx  # Linux
brew install nginx          # macOS

# Copiază build
sudo cp -r react-viewer/build/* /var/www/html/

# Restartează nginx
sudo systemctl restart nginx  # Linux
brew services restart nginx   # macOS
```

## Script-uri Utile

### FFmpeg Recording

```bash
cd scripts
chmod +x record_stream.sh
./record_stream.sh
```

### Python Recording

```bash
# Instalează dependențe
pip3 install opencv-python numpy

# Rulează cu preview
cd scripts
chmod +x record_stream.py
./record_stream.py --host localhost --preview
```

## Variabile de Mediu

Creează `.env.local` în `react-viewer/`:

```bash
REACT_APP_MEDIAMTX_HOST=localhost
REACT_APP_WEBRTC_PORT=8889
REACT_APP_HLS_PORT=8888
```

## Troubleshooting

### Port deja în uz

```bash
# Găsește procesul
lsof -i :3000  # sau 8889, 8554, etc.

# Omoară procesul
kill -9 <PID>
```

### Node modules corupte

```bash
cd react-viewer
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

### MediaMTX nu pornește

```bash
# Verifică dacă există procese pe porturi
netstat -tuln | grep -E '8554|8888|8889'

# Oprește procesele
sudo killall mediamtx
```

### Permission denied pentru script-uri

```bash
chmod +x scripts/*.sh scripts/*.py
```

## Performance Tips

1. **Folosește TCP pentru RTSP** (mai stabil în LAN)
2. **Optimizează bitrate-ul pe Jetson** (reduce latența)
3. **WebRTC > HLS** pentru latență minimă
4. **Închide alte aplicații** care folosesc bandwidth

## Next Steps

1. ✅ Modifică componentele React după nevoile tale
2. ✅ Adaugă funcționalități custom
3. ✅ Integrează cu alte servicii
4. ✅ Când ești gata, fă build pentru producție

---

**Happy Coding! 🚀**
