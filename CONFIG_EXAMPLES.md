# ⚙️ Exemple de Configurare

Acest fișier conține exemple de configurare pentru diferite scenarii de utilizare.

## Scenarii Comune

### 1. Demo Local (Jetson + Laptop în LAN)

**Setup:**
- Jetson: `192.168.1.100`
- Laptop: `192.168.1.50`

**mediamtx.yml:**
```yaml
paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    sourceProtocol: automatic
    sourceOnDemand: no
```

**.env:**
```bash
JETSON_IP=192.168.1.100
MEDIAMTX_HOST=192.168.1.50  # IP-ul laptop-ului
```

**Acces:**
- De pe laptop: `http://localhost:3000`
- De pe alt device în LAN: `http://192.168.1.50:3000`

---

### 2. Multiple Streams (Mai multe camere)

**mediamtx.yml:**
```yaml
paths:
  # Camera 1 - Intrare
  jetson_entrance:
    source: rtsp://192.168.1.100:8554/entrance
    sourceProtocol: automatic
    sourceOnDemand: no
  
  # Camera 2 - Parcare
  jetson_parking:
    source: rtsp://192.168.1.101:8554/parking
    sourceProtocol: automatic
    sourceOnDemand: no
  
  # Camera 3 - Interior
  jetson_interior:
    source: rtsp://192.168.1.102:8554/interior
    sourceProtocol: automatic
    sourceOnDemand: no
```

**Conectare în React:**
```javascript
// Schimbă STREAM_PATH în App.js
const STREAM_PATH = 'jetson_entrance';  // sau 'jetson_parking', 'jetson_interior'
```

---

### 3. Recording Automat (Server-side cu MediaMTX)

**mediamtx.yml:**
```yaml
paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    sourceProtocol: automatic
    sourceOnDemand: no
    
    # Activează recording automat
    record: yes
    recordPath: /recordings/%path/%Y-%m-%d_%H-%M-%S-%f
    recordFormat: mp4
    recordPartDuration: 1h
    recordSegmentDuration: 1h
    recordDeleteAfter: 24h  # Șterge după 24h
```

**docker-compose.yml:**
```yaml
services:
  mediamtx:
    volumes:
      - ./mediamtx/mediamtx.yml:/mediamtx.yml
      - /mnt/storage/recordings:/recordings  # Volume extern
```

---

### 4. Acces Public (Cu Port Forwarding)

**⚠️ Atenție:** Expune doar dacă ai SSL/TLS și autentificare!

**Router Port Forwarding:**
```
External Port → Internal IP:Port
8889 → 192.168.1.50:8889  (WebRTC)
3000 → 192.168.1.50:3000  (React App)
```

**mediamtx.yml (cu autentificare):**
```yaml
# Autentificare
authMethod: internal
authInternalUsers:
  - user: admin
    pass: parola_ta_foarte_sigura
    ips: []
    permissions:
      - action: read
      - action: publish

paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    readUser: admin
    readPass: parola_ta_foarte_sigura
```

---

### 5. Low Latency (Optimizat pentru latență minimă)

**mediamtx.yml:**
```yaml
# Optimizări pentru latență
readTimeout: 5s
writeTimeout: 5s
readBufferCount: 64
udpMaxPayloadSize: 1472

webrtc: yes
webrtcAddress: :8889
webrtcICEServers2:
  - urls: [stun:stun.l.google.com:19302]
webrtcICETCPMuxAddress: :8189
webrtcICEUDPMuxAddress: :8189

paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    sourceProtocol: tcp  # TCP mai stabil
    sourceOnDemand: no
    runOnReady: echo "Low latency stream ready"
```

**Jetson DeepStream config (pentru referință):**
```ini
[streammux]
buffer-pool-size=4
batch-size=1
batched-push-timeout=33333  # ~30 FPS

[sink0]
type=4  # RTSP
rtsp-port=8554
sync=0  # Disable sync pentru latență mai mică
```

---

### 6. High Quality Recording (Calitate maximă)

**record_stream.sh (modificat):**
```bash
# Înregistrare cu calitate maximă și metadate
ffmpeg \
    -rtsp_transport tcp \
    -i "$RTSP_URL" \
    -c:v libx264 \
    -preset slow \
    -crf 18 \
    -c:a aac \
    -b:a 192k \
    -movflags +faststart \
    -metadata title="Recording 360°" \
    -metadata author="Vladuceanu Tudor" \
    -metadata date="$(date +%Y-%m-%d)" \
    -y \
    "$OUTPUT_FILE"
```

---

### 7. Bandwidth Limited (Rețea limitată)

**mediamtx.yml:**
```yaml
paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    sourceProtocol: tcp
    
    # Limitează bitrate-ul pentru HLS
    runOnReady: >
      ffmpeg -i rtsp://localhost:8554/jetson360
      -c:v libx264 -b:v 1M -maxrate 1M -bufsize 2M
      -c:a aac -b:a 128k
      -f rtsp rtsp://localhost:8554/jetson360_low
```

**React App (.env):**
```bash
REACT_APP_STREAM_PATH=jetson360_low
```

---

### 8. Development Mock (Fără Jetson)

Pentru dezvoltare fără hardware:

**mediamtx.yml:**
```yaml
paths:
  jetson360:
    # Folosește un fișier video local ca sursă
    source: file:///home/user/test_videos/360_sample.mp4
    sourceProtocol: automatic
    sourceOnDemand: yes
```

Sau cu FFmpeg loop:

```bash
# Terminal separat - simulează Jetson
ffmpeg -re -stream_loop -1 -i sample_360.mp4 \
    -c copy -f rtsp rtsp://localhost:8554/jetson360
```

---

### 9. Multi-viewer (Mai mulți clienți)

**mediamtx.yml:**
```yaml
# Optimizare pentru mai mulți clienți
readBufferCount: 2048

webrtc: yes
webrtcICEServers2:
  - urls: 
    - stun:stun.l.google.com:19302
    - stun:stun1.l.google.com:19302

paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    sourceOnDemand: no
    # Permite mai multe conexiuni simultane
    runOnReady: echo "Stream ready for multiple viewers"
```

**Nginx load balancer (opțional):**
```nginx
upstream mediamtx_servers {
    server 192.168.1.50:8889;
    server 192.168.1.51:8889;
    server 192.168.1.52:8889;
}

server {
    listen 80;
    location / {
        proxy_pass http://mediamtx_servers;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

### 10. Debug Mode (Pentru troubleshooting)

**mediamtx.yml:**
```yaml
# Log level ridicat
logLevel: debug
logDestinations: [stdout, file]
logFile: /var/log/mediamtx/mediamtx.log

# Metrici active
metrics: yes
metricsAddress: :9998

# API activat
api: yes
apiAddress: :9997

paths:
  jetson360:
    source: rtsp://192.168.1.100:8554/video360
    sourceProtocol: tcp
    sourceOnDemand: no
    runOnReady: echo "[$(date)] Stream jetson360 is READY"
    runOnNotReady: echo "[$(date)] Stream jetson360 is NOT READY"
    runOnRead: echo "[$(date)] Client connected to jetson360"
```

**Monitorizare metrici:**
```bash
# Verifică metrici
curl http://localhost:9998/metrics

# Verifică API
curl http://localhost:9997/v3/config/paths/list
```

---

## Tips & Best Practices

### Performance
- Folosește **TCP** pentru RTSP în LAN (mai stabil)
- Activează **hardware acceleration** pe Jetson
- Dezactivează **sync** în RTSP sink pentru latență mai mică

### Security
- **Nu expune** MediaMTX direct pe internet fără SSL
- Folosește **autentificare** pentru production
- Implementează **rate limiting** pentru API

### Recording
- **Rotație automată** a fișierelor (recordDeleteAfter)
- **Verifică spațiul** de stocare regulat
- Folosește **SSD** pentru I/O mai rapid

### Networking
- **Static IP** pentru Jetson (sau DHCP reservation)
- **QoS** pentru trafic video dacă ai alte servicii în LAN
- **Gigabit ethernet** recomandat pentru 360° high quality

---

**Alege configurația potrivită pentru use case-ul tău! 🎯**
