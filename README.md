# 🎥 Vizualizator Stream 360° RTSP

> Soluție end-to-end pentru vizualizarea și salvarea stream-urilor video 360° prin RTSP, dezvoltată de **Vladuceanu Tudor**

## 📋 Cuprins

- [Prezentare Generală](#prezentare-generală)
- [Arhitectura Sistemului](#arhitectura-sistemului)
- [Cerințe Preliminare](#cerințe-preliminare)
- [Instalare și Configurare](#instalare-și-configurare)
- [Utilizare](#utilizare)
- [Funcționalități](#funcționalități)
- [Troubleshooting](#troubleshooting)
- [Structura Proiectului](#structura-proiectului)

---

## 🎯 Prezentare Generală

Acest proiect implementează **stația client** din arhitectura de procesare video 360° descrisă în documentul de proiect. Soluția permite:

✅ **Vizualizare live** a stream-ului 360° de la Jetson AGX Xavier  
✅ **Salvare locală** a înregistrărilor video  
✅ **Vizualizare interactivă** cu control de cameră (simulare VR)  
✅ **Bounding boxes vizibile** din DeepStream integrate direct în stream  
✅ **Latență minimă** prin WebRTC (~100ms)  

### Stack Tehnologic

- **Backend**: MediaMTX (conversie RTSP → WebRTC/HLS)
- **Frontend**: React + Three.js pentru vizualizare 360°
- **Recording**: FFmpeg + MediaRecorder API
- **Deployment**: Docker Compose

---

## 🏗️ Arhitectura Sistemului

```
┌─────────────────────────────────────────────────────────────────┐
│                      JETSON AGX XAVIER                          │
│  DeepStream Pipeline: Video 360° + AI Inference + OSD           │
│                 RTSP Output: port 8554                          │
└────────────────────────┬────────────────────────────────────────┘
                         │ RTSP Stream (LAN)
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   STAȚIA DE VIZUALIZARE                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              MediaMTX Server                            │   │
│  │  • Primește RTSP de la Jetson                          │   │
│  │  • Convertește în WebRTC (port 8889)                   │   │
│  │  • Convertește în HLS (port 8888)                      │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                         │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │          React Web Application (port 3000)              │   │
│  │  • Conectare WebRTC/HLS la MediaMTX                    │   │
│  │  • Vizualizare 360° cu Three.js                        │   │
│  │  • Salvare locală cu MediaRecorder API                 │   │
│  │  • Control interactiv cameră                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │        Script-uri de Salvare (Opțional)                │   │
│  │  • record_stream.sh (FFmpeg)                           │   │
│  │  • record_stream.py (OpenCV + Python)                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Cerințe Preliminare

### Software Necesar

- **Docker** & **Docker Compose** (pentru deployment containerizat)
- **Node.js 18+** & **npm** (pentru dezvoltare locală)
- **FFmpeg** (opțional, pentru script-uri de salvare)
- **Python 3.8+** & **OpenCV** (opțional, pentru script Python)

### Hardware

- **Jetson AGX Xavier** cu DeepStream configurat să transmită RTSP
- **Laptop/Stație** cu conexiune la același LAN
- **Browser modern** (Chrome, Firefox, Edge) pentru WebRTC

### Rețea

- Jetson și stația în **același LAN**
- Porturi deschise:
  - `8554` - RTSP
  - `8888` - HLS
  - `8889` - WebRTC
  - `3000` - React App
  - `9997`, `9998` - API & Metrics (opțional)

---

## 🚀 Instalare și Configurare

### Clonare Proiect

```bash
git clone <repository-url>
cd rtsp-viewer-project
```

### Configurare Variabile de Mediu

Editează fișierul `.env` cu IP-ul Jetson-ului tău:

```bash
# .env
JETSON_IP=192.168.1.100        # Înlocuiește cu IP-ul Jetson-ului
JETSON_RTSP_PORT=8554
MEDIAMTX_HOST=localhost
STREAM_PATH=jetson360
```

### Configurare MediaMTX

Editează `mediamtx/mediamtx.yml` și verifică secțiunea `paths`:

```yaml
paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360  # IP-ul Jetson-ului
    sourceProtocol: automatic
    sourceOnDemand: no
```

---

## 🎬 Utilizare

### Metoda 1: Docker Compose (Recomandat)

```bash
# Pornește toate serviciile
docker-compose up -d

# Verifică status
docker-compose ps

# Vezi log-uri
docker-compose logs -f

# Oprește serviciile
docker-compose down
```

**Acces aplicație**: `http://localhost:3000`

### Metoda 2: Dezvoltare Locală

#### Pornește MediaMTX

```bash
# Descarcă MediaMTX
wget https://github.com/bluenviron/mediamtx/releases/download/v1.6.0/mediamtx_v1.6.0_linux_amd64.tar.gz
tar -xzf mediamtx_v1.6.0_linux_amd64.tar.gz

# Rulează cu config custom
./mediamtx mediamtx/mediamtx.yml
```

#### Pornește React App

```bash
cd react-viewer

# Instalează dependențe
npm install

# Pornește development server
npm start
```

**Acces aplicație**: `http://localhost:3000`

### Metoda 3: Script-uri de Salvare Standalone

#### FFmpeg Script (Bash)

```bash
cd scripts

# Salvează stream pentru 60 secunde
./record_stream.sh

# Cu configurare custom
MEDIAMTX_HOST=192.168.1.50 OUTPUT_DIR=/mnt/recordings ./record_stream.sh
```

#### Python Script (OpenCV)

```bash
cd scripts

# Cu preview vizual (necesită GUI)
./record_stream.py --host 192.168.1.100 --preview

# Headless (pentru servere) - 60 secunde
./record_stream.py --host localhost --headless --duration 60

# Sau cu URL complet
./record_stream.py --url rtsp://192.168.1.100:8554/jetson360 --preview
```

**Instalare dependențe Python:**

```bash
pip install opencv-python numpy
```

---

## ✨ Funcționalități

### 🌐 Aplicația Web React

#### 1. **Conectare la Stream**
- **WebRTC**: Latență minimă (~100ms) - ideal pentru live monitoring
- **HLS**: Compatibilitate maximă (~3-5s latență) - fallback pentru browsere mai vechi

#### 2. **Vizualizare 360°**
- Sferă inversată cu textura video aplicată
- Control interactiv cu mouse:
  - **Click + Drag**: Rotire cameră
  - **Scroll**: Zoom in/out
- Bounding boxes de la DeepStream vizibile direct în stream

#### 3. **Salvare Locală**
- Înregistrare direct în browser cu MediaRecorder API
- Format: WebM (VP9/VP8)
- Calitate: 2.5 Mbps
- Download automat fișier local

#### 4. **Interface Intuitivă**
- Status conexiune real-time
- Controale simple și clare
- Informații tehnice despre stream
- Design responsive (desktop + mobile)

### 📹 Script-uri de Salvare

#### FFmpeg Script
- ✅ Salvare cu calitate originală (copy codec)
- ✅ Format MP4 compatibil
- ✅ TCP transport pentru stabilitate
- ✅ Fast start pentru playback rapid

#### Python Script
- ✅ Preview live cu GUI (OpenCV)
- ✅ Snapshot-uri la cerere
- ✅ Control prin taste (R - record, S - snapshot, Q - quit)
- ✅ Mod headless pentru servere
- ✅ Înregistrare cu durată specificată

---

## 🔧 Troubleshooting

### Problema 1: Nu se conectează la stream WebRTC

**Verificări:**
1. MediaMTX server pornit:
   ```bash
   docker-compose logs mediamtx
   ```

2. Jetson trimite RTSP la MediaMTX:
   ```bash
   ffprobe rtsp://192.168.1.100:8554/video360
   ```

3. Port 8889 deschis:
   ```bash
   netstat -tuln | grep 8889
   ```

4. Firewall permite conexiuni:
   ```bash
   sudo ufw allow 8889/tcp
   ```

### Problema 2: Stream întrerupt sau latență mare

**Soluții:**

1. **Folosește TCP în loc de UDP:**
   ```yaml
   # mediamtx.yml
   protocols: [tcp]
   ```

2. **Reduce bitrate pe Jetson** (în DeepStream config)

3. **Verifică bandwidth-ul rețelei:**
   ```bash
   iperf3 -c 192.168.1.100
   ```

### Problema 3: Bounding boxes nu apar

**Verificare:**
- OSD activat în DeepStream pipeline (nvdsosd plugin)
- Stream-ul de la Jetson **include** bounding boxes înainte de RTSP output

### Problema 4: Aplicația React nu pornește

```bash
cd react-viewer

# Curăță node_modules și reinstalează
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps

# Verifică versiunea Node
node --version  # Trebuie să fie 18+
```

### Problema 5: FFmpeg nu găsește stream-ul

```bash
# Testează direct cu VLC sau ffplay
ffplay rtsp://localhost:8554/jetson360

# Sau cu FFmpeg
ffmpeg -rtsp_transport tcp -i rtsp://localhost:8554/jetson360 -f null -
```

---

## 📁 Structura Proiectului

```
rtsp-viewer-project/
├── docker-compose.yml              # Orchestrare servicii
├── .env                            # Variabile de mediu
├── README.md                       # Documentație
│
├── mediamtx/                       # MediaMTX Server
│   └── mediamtx.yml               # Configurare RTSP→WebRTC
│
├── react-viewer/                   # Aplicația Web React
│   ├── Dockerfile                 # Container pentru producție
│   ├── nginx.conf                 # Config nginx
│   ├── package.json               # Dependențe Node.js
│   ├── public/
│   │   └── index.html            # HTML template
│   └── src/
│       ├── App.js                # Componenta principală
│       ├── App.css               # Stiluri principale
│       ├── index.js              # Entry point
│       └── components/
│           ├── Video360Viewer.js     # Vizualizare 360° Three.js
│           ├── StreamController.js   # Control conexiune
│           ├── RecordingPanel.js     # Salvare stream
│           └── *.css                 # Stiluri componente
│
├── scripts/                        # Script-uri utile
│   ├── record_stream.sh           # FFmpeg recording (Bash)
│   └── record_stream.py           # OpenCV recording (Python)
│
└── recordings/                     # Director salvări (creat automat)
```

---

## 🎓 Concepte Tehnice

### WebRTC vs HLS

| Aspect | WebRTC | HLS |
|--------|--------|-----|
| **Latență** | ~100ms | 3-5s |
| **Compatibilitate** | Browsere moderne | Toate browserele |
| **Bandwidth** | Adaptiv | Fix |
| **Firewall** | Poate avea probleme | Funcționează peste HTTP |
| **Când să folosești** | Live monitoring | Broadcasting |

### Cum Funcționează Vizualizarea 360°

1. **Stream video** devine **textura Three.js**
2. Textura se aplică pe o **sferă inversată** (normale orientate spre interior)
3. Camera este poziționată în **centrul sferei**
4. Utilizatorul controlează **rotația camerei**, nu a sferei
5. Bounding boxes sunt **parte din textura video** (desenate de DeepStream)

### Pipeline de Date

```
[Jetson: DeepStream] 
    → H.264 encoded video cu OSD
    → RTSP packet stream
    → [MediaMTX: RTSP ingest]
    → Decodare + Re-pachetare
    → [MediaMTX: WebRTC output]
    → RTP packets
    → [Browser: WebRTC receiver]
    → Video track în MediaStream
    → [React: Video element]
    → [Three.js: VideoTexture]
    → Rendering pe sferă inversată
```

---

## 📚 Resurse Suplimentare

### Documentație
- [MediaMTX GitHub](https://github.com/bluenviron/mediamtx)
- [Three.js Documentation](https://threejs.org/docs/)
- [WebRTC API](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)

### Tutoriale
- [RTSP Streaming with FFmpeg](https://trac.ffmpeg.org/wiki/StreamingGuide)
- [Three.js 360° Video](https://threejs.org/examples/#webgl_materials_video)
- [React + WebRTC](https://webrtc.org/getting-started/overview)

---

## 👨‍💻 Autor

**Vladuceanu Tudor**  
Proiect: *Soluție de procesare a unui flux video 360° pentru detecție obiecte*

---

## 📝 Licență

Acest proiect este dezvoltat în scop educațional ca parte a unei lucrări academice.

---

## 🙏 Mulțumiri

- NVIDIA pentru DeepStream SDK
- BluenViron pentru MediaMTX
- Comunitatea Three.js
- Comunitatea React

---

**Enjoy streaming! 🎥✨**
