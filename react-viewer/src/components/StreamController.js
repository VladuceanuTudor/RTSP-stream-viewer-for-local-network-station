import React, { useState } from 'react';
import './StreamController.css';

export default function StreamController({ 
  isConnected, 
  streamType, 
  onConnect, 
  onDisconnect,
  mediamtxHost 
}) {
  const [customHost, setCustomHost] = useState(mediamtxHost);
  const [showAdvanced, setShowAdvanced] = useState(false);

  return (
    <div className="stream-controller">
      <h3>🔌 Conexiune Stream</h3>
      
      <div className="connection-status">
        <div className={`status-indicator ${isConnected ? 'connected' : 'disconnected'}`}>
          {isConnected ? '🟢 Conectat' : '🔴 Deconectat'}
        </div>
        {isConnected && (
          <div className="protocol-badge">
            {streamType.toUpperCase()}
          </div>
        )}
      </div>

      {!isConnected ? (
        <div className="connect-buttons">
          <button 
            className="btn btn-primary"
            onClick={() => onConnect('webrtc')}
          >
            🚀 Conectare WebRTC
          </button>
          
          <button 
            className="btn btn-secondary"
            onClick={() => onConnect('hls')}
          >
            📺 Conectare HLS
          </button>

          <div className="protocol-info">
            <p><strong>WebRTC:</strong> Latență minimă (~100ms)</p>
            <p><strong>HLS:</strong> Compatibilitate mare (~3-5s latență)</p>
          </div>
        </div>
      ) : (
        <button 
          className="btn btn-danger"
          onClick={onDisconnect}
        >
          ⛔ Deconectare
        </button>
      )}

      <div className="advanced-settings">
        <button 
          className="btn-link"
          onClick={() => setShowAdvanced(!showAdvanced)}
        >
          ⚙️ {showAdvanced ? 'Ascunde' : 'Arată'} Setări Avansate
        </button>

        {showAdvanced && (
          <div className="settings-panel">
            <label>
              Host MediaMTX:
              <input 
                type="text" 
                value={customHost}
                onChange={(e) => setCustomHost(e.target.value)}
                placeholder="localhost sau IP"
              />
            </label>
            
            <div className="endpoints-info">
              <h4>Endpoint-uri:</h4>
              <code>WebRTC: {customHost}:8889/jetson360/whep</code>
              <code>HLS: {customHost}:8888/jetson360/index.m3u8</code>
              <code>RTSP: {customHost}:8554/jetson360</code>
            </div>
          </div>
        )}
      </div>

      <div className="connection-guide">
        <h4>📋 Checklist</h4>
        <ul>
          <li>✅ MediaMTX server pornit</li>
          <li>✅ Jetson trimite RTSP</li>
          <li>✅ Port 8889 deschis</li>
          <li>✅ Același LAN</li>
        </ul>
      </div>
    </div>
  );
}
