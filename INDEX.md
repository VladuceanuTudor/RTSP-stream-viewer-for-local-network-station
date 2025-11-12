# 🎥 RTSP 360° Viewer - Index Navigare

Bun venit! Acest proiect oferă o soluție completă pentru vizualizarea și salvarea stream-urilor video 360° de la Jetson AGX Xavier.

---

## 🚀 Pornire Rapidă - Citește Mai Întâi

| Fișier | Când să-l folosești |
|--------|-------------------|
| **[QUICKSTART.md](QUICKSTART.md)** | 👈 **START AICI!** Pentru a porni proiectul în 5 minute |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Pentru overview complet al proiectului |

---

## 📚 Documentație Detaliată

| Fișier | Scop |
|--------|------|
| **[README.md](README.md)** | Documentație completă - arhitectură, instalare, utilizare |
| **[LOCAL_DEV.md](LOCAL_DEV.md)** | Setup pentru dezvoltare locală (fără Docker) |
| **[CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md)** | 10+ exemple de configurare pentru scenarii diferite |

---

## 🎯 Workflow Recomandat

### Pentru Prima Rulare (Demo)
```
1. Citește QUICKSTART.md (5 min)
2. Editează .env cu IP-ul Jetson
3. Rulează: make start
4. Deschide http://localhost:3000
5. Conectează-te la stream
```

### Pentru Dezvoltare
```
1. Citește LOCAL_DEV.md
2. Setup MediaMTX + React local
3. Modifică componentele în react-viewer/src/
4. Testează cu hot reload
```

### Pentru Producție
```
1. Citește CONFIG_EXAMPLES.md - Secțiunea "Acces Public"
2. Configurează SSL + autentificare
3. Build cu: make build-docker
4. Deploy cu: docker-compose up -d
```

---

## 📁 Structura Proiectului

```
rtsp-viewer-project/
│
├── 📄 INDEX.md                    ← Ești aici!
├── 📄 QUICKSTART.md               ← START AICI pentru demo rapid
├── 📄 PROJECT_SUMMARY.md          ← Overview complet
├── 📄 README.md                   ← Documentație detaliată
├── 📄 LOCAL_DEV.md                ← Setup dezvoltare
├── 📄 CONFIG_EXAMPLES.md          ← Exemple configurare
│
├── 🐳 docker-compose.yml          ← Orchestrare Docker
├── ⚙️  .env                       ← Configurare (EDITEAZĂ IP JETSON!)
├── 🔨 Makefile                    ← Comenzi rapide
│
├── 📁 mediamtx/
│   └── mediamtx.yml              ← Config server RTSP→WebRTC
│
├── 📁 react-viewer/               ← Aplicația React
│   ├── src/
│   │   ├── App.js               ← Componenta principală
│   │   └── components/          ← Video360, Controller, Recording
│   ├── package.json
│   ├── Dockerfile
│   └── nginx.conf
│
└── 📁 scripts/                    ← Script-uri utile
    ├── record_stream.sh          ← Salvare cu FFmpeg
    ├── record_stream.py          ← Salvare cu OpenCV
    └── validate.sh               ← Validare sistem
```

---

## 🛠️ Comenzi Utile Rapide

```bash
# Vezi toate comenzile disponibile
make help

# Pornește proiectul
make start

# Verifică dacă totul e OK
make validate

# Vezi log-uri
make logs

# Oprește proiectul
make stop
```

---

## 🎓 Ce Vei Învăța Din Acest Proiect

### Frontend
- ✅ React cu Hooks moderne
- ✅ Three.js pentru renderare 3D
- ✅ WebRTC API integration
- ✅ MediaRecorder pentru salvare video

### Backend
- ✅ RTSP streaming protocol
- ✅ MediaMTX server configuration
- ✅ Video codec conversion
- ✅ Real-time streaming optimization

### DevOps
- ✅ Docker multi-container setup
- ✅ Nginx configuration
- ✅ Environment management
- ✅ Production deployment

### Video Processing
- ✅ 360° video handling
- ✅ Equirectangular projection
- ✅ Real-time video streaming
- ✅ Recording strategies

---

## 📊 Features Implementate

### Vizualizare
- [x] Stream 360° interactiv cu Three.js
- [x] Control cameră cu mouse (drag, zoom)
- [x] Bounding boxes de la DeepStream vizibile
- [x] UI modern și responsive

### Conectivitate
- [x] WebRTC pentru latență minimă (~100ms)
- [x] HLS ca fallback pentru compatibilitate
- [x] Auto-reconnect la pierdere conexiune
- [x] Status real-time în UI

### Salvare
- [x] Recording în browser cu MediaRecorder
- [x] Script FFmpeg pentru calitate maximă
- [x] Script Python cu preview live
- [x] Auto-recording configurabil

### Deployment
- [x] Docker Compose setup complet
- [x] Development mode cu hot reload
- [x] Production build optimizat
- [x] Script validare automată

---

## 🔍 Troubleshooting Rapid

| Problemă | Citește |
|----------|---------|
| "Nu știu de unde să încep" | QUICKSTART.md |
| "Nu se conectează la stream" | README.md → Troubleshooting |
| "Vreau să dezvolt local" | LOCAL_DEV.md |
| "Cum configurez pentru X?" | CONFIG_EXAMPLES.md |
| "Ce tehnologii sunt folosite?" | PROJECT_SUMMARY.md |

---

## 💡 Tips

### Pentru Succes Rapid
1. **Asigură-te** că Jetson și laptop sunt în **același LAN**
2. **Verifică** că porturile nu sunt blocate de firewall
3. **Rulează** `make validate` înainte de demo
4. **Folosește WebRTC** în loc de HLS pentru latență minimă

### Pentru Demo Perfect
1. **Pregătește** stream-ul de test înainte
2. **Testează** conexiunea cu `ffprobe`
3. **Ai backup** cu recording pre-făcut
4. **Explică** arhitectura folosind diagrama din README

---

## 📞 Need Help?

1. **Rulează validare**: `./scripts/validate.sh`
2. **Verifică log-uri**: `make logs`
3. **Consultă**: Secțiunea Troubleshooting din README.md
4. **Testează**: Exemplele din CONFIG_EXAMPLES.md

---

## 🎯 Quick Links

- **Aplicația Web**: http://localhost:3000 (după `make start`)
- **MediaMTX API**: http://localhost:9997
- **HLS Stream**: http://localhost:8888/jetson360/index.m3u8
- **Metrics**: http://localhost:9998/metrics

---

## 🎉 Ready to Go!

1. **Citește** [QUICKSTART.md](QUICKSTART.md) (5 minute)
2. **Editează** `.env` cu IP-ul Jetson
3. **Rulează** `make start`
4. **Enjoy** streaming 360°! 🚀

---

**Happy Streaming! 🎥✨**

*Developed by Vladuceanu Tudor*
