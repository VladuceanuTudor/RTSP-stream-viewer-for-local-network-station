import React, { useRef, useEffect, useState } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';
import * as THREE from 'three';

// Componenta pentru sfera 360° cu textura video
function VideoSphere({ videoRef }) {
  const meshRef = useRef();
  const [videoTexture, setVideoTexture] = useState(null);

  useEffect(() => {
    if (videoRef.current && videoRef.current.readyState >= videoRef.current.HAVE_METADATA) {
      const texture = new THREE.VideoTexture(videoRef.current);
      texture.minFilter = THREE.LinearFilter;
      texture.magFilter = THREE.LinearFilter;
      texture.format = THREE.RGBFormat;
      setVideoTexture(texture);
    }

    const handleLoadedMetadata = () => {
      const texture = new THREE.VideoTexture(videoRef.current);
      texture.minFilter = THREE.LinearFilter;
      texture.magFilter = THREE.LinearFilter;
      texture.format = THREE.RGBFormat;
      setVideoTexture(texture);
    };

    if (videoRef.current) {
      videoRef.current.addEventListener('loadedmetadata', handleLoadedMetadata);
      return () => {
        if (videoRef.current) {
          videoRef.current.removeEventListener('loadedmetadata', handleLoadedMetadata);
        }
      };
    }
  }, [videoRef]);

  useFrame(() => {
    if (videoTexture) {
      videoTexture.needsUpdate = true;
    }
  });

  return (
    <mesh ref={meshRef} scale={[-1, 1, 1]}>
      {/* Sfera inversată pentru vizualizare 360° */}
      <sphereGeometry args={[500, 60, 40]} />
      <meshBasicMaterial 
        map={videoTexture} 
        side={THREE.BackSide}
        toneMapped={false}
      />
    </mesh>
  );
}

// Componenta pentru camera controlată
function CameraController() {
  const { camera } = useThree();
  
  useEffect(() => {
    camera.position.set(0, 0, 0.1);
  }, [camera]);

  return null;
}

// Componenta principală
export default function Video360Viewer({ videoRef, streamUrl, streamType }) {
  const [showControls, setShowControls] = useState(true);

  return (
    <div className="viewer-container">
      <div className="viewer-canvas">
        <Canvas camera={{ fov: 75, position: [0, 0, 0.1] }}>
          <CameraController />
          <VideoSphere videoRef={videoRef} />
          <OrbitControls 
            enableZoom={true}
            enablePan={false}
            enableDamping={true}
            dampingFactor={0.05}
            rotateSpeed={-0.5}
            minDistance={0.1}
            maxDistance={1}
          />
          <ambientLight intensity={1} />
        </Canvas>
      </div>

      {/* Video element ascuns pentru WebRTC */}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        style={{ display: 'none' }}
        src={streamType === 'hls' ? streamUrl : undefined}
      />

      {/* Controale pentru vizualizare */}
      <div className="viewer-controls">
        <button 
          className="toggle-controls"
          onClick={() => setShowControls(!showControls)}
        >
          {showControls ? '🎮 Ascunde Controale' : '🎮 Arată Controale'}
        </button>
        
        {showControls && (
          <div className="controls-info">
            <h4>Controale:</h4>
            <ul>
              <li><strong>Click + Drag:</strong> Rotește camera</li>
              <li><strong>Scroll:</strong> Zoom in/out</li>
              <li><strong>Click dreapta + Drag:</strong> Pan (dacă e activat)</li>
            </ul>
            <p className="tip">💡 Bounding box-urile de la DeepStream sunt vizibile direct în stream!</p>
          </div>
        )}
      </div>
    </div>
  );
}
