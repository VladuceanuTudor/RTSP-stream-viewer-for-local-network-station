import React, { useState, useRef, useEffect } from 'react';
import './App.css';
import Video360Viewer from './components/Video360Viewer';
import StreamController from './components/StreamController';
import RecordingPanel from './components/RecordingPanel';

function App() {
  const [streamUrl, setStreamUrl] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [streamType, setStreamType] = useState('webrtc'); // 'webrtc' sau 'hls'
  const videoRef = useRef(null);

  // Configurare din environment variables
  const MEDIAMTX_HOST = process.env.REACT_APP_MEDIAMTX_HOST || 'localhost';
  const WEBRTC_PORT = process.env.REACT_APP_WEBRTC_PORT || '8889';
  const HLS_PORT = process.env.REACT_APP_HLS_PORT || '8888';
  const STREAM_PATH = 'jetson360';

  const connectToStream = async (type) => {
    setStreamType(type);
    
    if (type === 'webrtc') {
      // Conectare WebRTC
      const webrtcUrl = `http://${MEDIAMTX_HOST}:${WEBRTC_PORT}/${STREAM_PATH}/whep`;
      await connectWebRTC(webrtcUrl);
    } else if (type === 'hls') {
      // Conectare HLS
      const hlsUrl = `http://${MEDIAMTX_HOST}:${HLS_PORT}/${STREAM_PATH}/index.m3u8`;
      setStreamUrl(hlsUrl);
      setIsConnected(true);
    }
  };

  const connectWebRTC = async (url) => {
    try {
      const pc = new RTCPeerConnection({
        iceServers: [{
          urls: 'stun:stun.l.google.com:19302'
        }]
      });

      // Ascultă pentru track-uri video
      pc.ontrack = (event) => {
        console.log('WebRTC track primit:', event.track.kind);
        if (videoRef.current && event.streams[0]) {
          videoRef.current.srcObject = event.streams[0];
          setIsConnected(true);
        }
      };

      // Setează transceivers pentru a primi video
      pc.addTransceiver('video', { direction: 'recvonly' });
      pc.addTransceiver('audio', { direction: 'recvonly' });

      // Creează oferta
      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);

      // Trimite oferta la server prin WHEP protocol
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/sdp',
        },
        body: offer.sdp,
      });

      if (!response.ok) {
        throw new Error(`Eroare WHEP: ${response.status}`);
      }

      const answerSdp = await response.text();
      await pc.setRemoteDescription({
        type: 'answer',
        sdp: answerSdp,
      });

      setStreamUrl('webrtc-connected');
      console.log('WebRTC conectat cu succes!');
    } catch (error) {
      console.error('Eroare conectare WebRTC:', error);
      alert(`Nu s-a putut conecta la stream: ${error.message}`);
    }
  };

  const disconnectStream = () => {
    if (videoRef.current) {
      if (videoRef.current.srcObject) {
        videoRef.current.srcObject.getTracks().forEach(track => track.stop());
        videoRef.current.srcObject = null;
      }
      videoRef.current.src = '';
    }
    setStreamUrl('');
    setIsConnected(false);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🎥 Vizualizator Stream 360° RTSP</h1>
        <p>Proiect procesare video panoramic - Vladuceanu Tudor</p>
      </header>

      <div className="app-container">
        <div className="sidebar">
          <StreamController
            isConnected={isConnected}
            streamType={streamType}
            onConnect={connectToStream}
            onDisconnect={disconnectStream}
            mediamtxHost={MEDIAMTX_HOST}
          />
          
          <RecordingPanel
            videoRef={videoRef}
            isConnected={isConnected}
          />
        </div>

        <div className="main-content">
          {isConnected ? (
            <Video360Viewer
              videoRef={videoRef}
              streamUrl={streamUrl}
              streamType={streamType}
            />
          ) : (
            <div className="no-stream">
              <div className="placeholder">
                <h2>📡 Niciun stream conectat</h2>
                <p>Conectează-te la stream-ul de la Jetson folosind butoanele din stânga</p>
                <div className="instructions">
                  <h3>Instrucțiuni:</h3>
                  <ol>
                    <li>Asigură-te că MediaMTX server rulează (port 8889 pentru WebRTC)</li>
                    <li>Verifică că Jetson trimite stream RTSP la MediaMTX</li>
                    <li>Apasă "Conectare WebRTC" pentru latență minimă</li>
                    <li>Sau folosește "Conectare HLS" ca fallback</li>
                  </ol>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      <footer className="App-footer">
        <p>Status: {isConnected ? '🟢 Conectat' : '🔴 Deconectat'} | 
           Protocol: {streamType.toUpperCase()} | 
           Host: {MEDIAMTX_HOST}</p>
      </footer>
    </div>
  );
}

export default App;
