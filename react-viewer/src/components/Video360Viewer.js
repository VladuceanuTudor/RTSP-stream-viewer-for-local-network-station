import React, { useRef, useEffect, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls } from '@react-three/drei';
import * as THREE from 'three';

function VideoSphere({ videoRef }) {
  const meshRef = useRef();
  const [texture, setTexture] = useState(null);

  useEffect(() => {
    console.log('VideoSphere mounted');
    
    if (!videoRef.current) {
      console.log('❌ No video ref!');
      return;
    }
    
    const video = videoRef.current;
    console.log('✅ Video found, readyState:', video.readyState, 'size:', video.videoWidth, 'x', video.videoHeight);
    
    const videoTexture = new THREE.VideoTexture(video);
    videoTexture.minFilter = THREE.LinearFilter;
    videoTexture.magFilter = THREE.LinearFilter;
    videoTexture.colorSpace = THREE.SRGBColorSpace;
    setTexture(videoTexture);
    console.log('✅ Texture created!');
    
  }, [videoRef]);

  useFrame(() => {
    if (texture) {
      texture.needsUpdate = true;
    }
  });

  return (
    <mesh ref={meshRef} scale={[-1, 1, 1]}>
      <sphereGeometry args={[500, 60, 40]} />
      <meshBasicMaterial 
        map={texture}
        side={THREE.BackSide}
      />
    </mesh>
  );
}

export default function Video360Viewer({ videoRef }) {
  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <Canvas camera={{ fov: 75, position: [0, 0, 0.1] }}>
        <VideoSphere videoRef={videoRef} />
        <OrbitControls 
          enableZoom={true}
          rotateSpeed={-0.5}
        />
      </Canvas>
    </div>
  );
}