import React, { useState, useRef } from 'react';
import './RecordingPanel.css';

export default function RecordingPanel({ videoRef, isConnected }) {
  const [isRecording, setIsRecording] = useState(false);
  const [recordedChunks, setRecordedChunks] = useState([]);
  const [recordingTime, setRecordingTime] = useState(0);
  const mediaRecorderRef = useRef(null);
  const timerRef = useRef(null);

  const startRecording = async () => {
    if (!videoRef.current || !videoRef.current.srcObject) {
      alert('Nu există stream video activ pentru înregistrare!');
      return;
    }

    try {
      const stream = videoRef.current.srcObject;
      const options = {
        mimeType: 'video/webm;codecs=vp9',
        videoBitsPerSecond: 2500000
      };

      // Verifică suportul pentru codec
      if (!MediaRecorder.isTypeSupported(options.mimeType)) {
        options.mimeType = 'video/webm';
      }

      const mediaRecorder = new MediaRecorder(stream, options);
      mediaRecorderRef.current = mediaRecorder;

      const chunks = [];
      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          chunks.push(event.data);
        }
      };

      mediaRecorder.onstop = () => {
        const blob = new Blob(chunks, { type: 'video/webm' });
        setRecordedChunks([blob]);
        stopTimer();
      };

      mediaRecorder.start(1000); // Salvează date la fiecare secundă
      setIsRecording(true);
      startTimer();

      console.log('Înregistrare pornită!');
    } catch (error) {
      console.error('Eroare pornire înregistrare:', error);
      alert('Nu s-a putut porni înregistrarea: ' + error.message);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      console.log('Înregistrare oprită!');
    }
  };

  const startTimer = () => {
    setRecordingTime(0);
    timerRef.current = setInterval(() => {
      setRecordingTime(prev => prev + 1);
    }, 1000);
  };

  const stopTimer = () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  };

  const downloadRecording = () => {
    if (recordedChunks.length === 0) {
      alert('Nu există înregistrări de descărcat!');
      return;
    }

    const blob = recordedChunks[0];
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    a.download = `recording-360-${new Date().toISOString()}.webm`;
    document.body.appendChild(a);
    a.click();
    
    setTimeout(() => {
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }, 100);

    console.log('Înregistrare descărcată!');
  };

  const clearRecording = () => {
    setRecordedChunks([]);
    setRecordingTime(0);
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="recording-panel">
      <h3>💾 Salvare Stream</h3>

      <div className="recording-status">
        {isRecording ? (
          <div className="recording-active">
            <span className="rec-indicator">🔴 REC</span>
            <span className="rec-time">{formatTime(recordingTime)}</span>
          </div>
        ) : (
          <div className="recording-idle">
            <span>⏸️ Inactiv</span>
          </div>
        )}
      </div>

      <div className="recording-controls">
        {!isRecording ? (
          <button 
            className="btn btn-record"
            onClick={startRecording}
            disabled={!isConnected}
          >
            ⏺️ Start Înregistrare
          </button>
        ) : (
          <button 
            className="btn btn-stop"
            onClick={stopRecording}
          >
            ⏹️ Stop Înregistrare
          </button>
        )}
      </div>

      {recordedChunks.length > 0 && (
        <div className="recorded-files">
          <h4>📁 Înregistrări:</h4>
          <div className="file-item">
            <span>📹 Video 360° ({(recordedChunks[0].size / 1024 / 1024).toFixed(2)} MB)</span>
            <div className="file-actions">
              <button 
                className="btn btn-small btn-download"
                onClick={downloadRecording}
              >
                ⬇️ Descarcă
              </button>
              <button 
                className="btn btn-small btn-delete"
                onClick={clearRecording}
              >
                🗑️ Șterge
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="recording-info">
        <h4>ℹ️ Info</h4>
        <ul>
          <li>Format: WebM (VP9/VP8)</li>
          <li>Calitate: 2.5 Mbps</li>
          <li>Bounding boxes incluse</li>
          <li>Salvare locală în browser</li>
        </ul>
        <p className="note">
          💡 Înregistrarea se face direct în browser folosind MediaRecorder API.
          Fișierul se salvează local pe stația ta.
        </p>
      </div>
    </div>
  );
}
