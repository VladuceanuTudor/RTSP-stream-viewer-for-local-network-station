# 🚀 Ghid Rapid de Pornire

## Setup în 5 minute

### Pas 1: Pregătire

```bash
# Clonează proiectul
git clone <repository-url>
cd rtsp-viewer-project

# Editează .env cu IP-ul Jetson-ului tău
nano .env
# Schimbă: JETSON_IP=192.168.1.XXX
```

### Pas 2: Pornire cu Docker

```bash
# Pornește toate serviciile
docker-compose up -d

# Verifică că totul rulează
docker-compose ps
```

### Pas 3: Accesează Aplicația

Deschide browser la: **http://localhost:3000**

### Pas 4: Conectare la Stream

1. Click pe **"Conectare WebRTC"** (latență minimă)
2. Sau folosește **"Conectare HLS"** dacă WebRTC nu funcționează
3. Vizualizează stream-ul 360° - **mișcă mouse-ul pentru a roti camera**!

### Pas 5: Salvare Video (Opțional)

**În aplicația web:**
- Click pe **"⏺️ Start Înregistrare"**
- Când termini, click pe **"⏹️ Stop Înregistrare"**
- Click pe **"⬇️ Descarcă"** pentru a salva local

**Sau cu script FFmpeg:**
```bash
cd scripts
./record_stream.sh
# Apasă Ctrl+C pentru a opri
```

---

## Troubleshooting Rapid

### Nu se conectează la stream?

```bash
# 1. Verifică MediaMTX
docker-compose logs mediamtx

# 2. Verifică că Jetson trimite RTSP
ffplay rtsp://192.168.1.XXX:8554/video360

# 3. Restartează serviciile
docker-compose restart
```

### Aplicația React nu pornește?

```bash
# Oprește Docker și rulează local
docker-compose down

cd react-viewer
npm install --legacy-peer-deps
npm start
```

### Latență mare?

- Folosește **WebRTC** în loc de HLS
- Verifică conexiunea de rețea
- Asigură-te că Jetson și stația sunt în **același LAN**

---

## Comenzi Utile

```bash
# Pornește serviciile
docker-compose up -d

# Oprește serviciile
docker-compose down

# Vezi log-uri live
docker-compose logs -f

# Restartează un serviciu specific
docker-compose restart mediamtx

# Rebuild după modificări
docker-compose up -d --build

# Curăță totul (inclusiv volume-uri)
docker-compose down -v
```

---

## IP-uri și Porturi

| Serviciu | URL | Descriere |
|----------|-----|-----------|
| **React App** | http://localhost:3000 | Aplicația web |
| **MediaMTX WebRTC** | http://localhost:8889 | Endpoint WebRTC |
| **MediaMTX HLS** | http://localhost:8888 | Endpoint HLS |
| **MediaMTX RTSP** | rtsp://localhost:8554 | Server RTSP |
| **MediaMTX API** | http://localhost:9997 | API monitoring |

---

## Next Steps

1. ✅ Verifică că bounding boxes de la DeepStream apar în stream
2. ✅ Testează salvarea video
3. ✅ Experimentează cu controalele de cameră
4. ✅ Citește [README.md](README.md) complet pentru funcționalități avansate

---

**Succes! 🎉**

Dacă întâmpini probleme, consultă secțiunea **Troubleshooting** din README.md.
