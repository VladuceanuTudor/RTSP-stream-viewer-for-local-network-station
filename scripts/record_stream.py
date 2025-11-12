#!/usr/bin/env python3
"""
Script Python pentru salvarea și procesarea stream-ului RTSP
Oferă funcționalități avansate: preview, snapshot, conversie format
Autor: Vladuceanu Tudor
"""

import cv2
import os
import sys
import argparse
from datetime import datetime
import time

class RTSPRecorder:
    def __init__(self, rtsp_url, output_dir='./recordings'):
        self.rtsp_url = rtsp_url
        self.output_dir = output_dir
        self.is_recording = False
        self.cap = None
        self.writer = None
        
        # Creează directorul de output
        os.makedirs(output_dir, exist_ok=True)
        
    def connect(self):
        """Conectare la stream RTSP"""
        print(f"🔌 Conectare la: {self.rtsp_url}")
        self.cap = cv2.VideoCapture(self.rtsp_url)
        
        if not self.cap.isOpened():
            raise Exception("❌ Nu s-a putut conecta la stream-ul RTSP!")
        
        # Obține proprietățile video
        self.fps = self.cap.get(cv2.CAP_PROP_FPS) or 30.0
        self.width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        self.height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        
        print(f"✅ Conectat! Rezoluție: {self.width}x{self.height} @ {self.fps} FPS")
        
    def start_recording(self, output_file=None):
        """Începe înregistrarea"""
        if output_file is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_file = os.path.join(self.output_dir, f"recording_360_{timestamp}.mp4")
        
        # Codec pentru MP4
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        self.writer = cv2.VideoWriter(output_file, fourcc, self.fps, 
                                     (self.width, self.height))
        
        if not self.writer.isOpened():
            raise Exception("❌ Nu s-a putut crea fișierul video!")
        
        self.is_recording = True
        self.output_file = output_file
        print(f"🔴 Înregistrare pornită: {output_file}")
        
    def stop_recording(self):
        """Oprește înregistrarea"""
        if self.writer:
            self.writer.release()
            self.writer = None
        self.is_recording = False
        print(f"⏹️  Înregistrare oprită")
        
        # Afișează informații despre fișier
        if os.path.exists(self.output_file):
            size_mb = os.path.getsize(self.output_file) / (1024 * 1024)
            print(f"✅ Fișier salvat: {self.output_file} ({size_mb:.2f} MB)")
    
    def take_snapshot(self, frame):
        """Salvează un snapshot al frame-ului curent"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        snapshot_file = os.path.join(self.output_dir, f"snapshot_{timestamp}.jpg")
        cv2.imwrite(snapshot_file, frame)
        print(f"📸 Snapshot salvat: {snapshot_file}")
        
    def run_with_preview(self):
        """Rulează cu preview vizual (necesită GUI)"""
        self.connect()
        frame_count = 0
        
        print("\n=== Controale ===")
        print("R - Start/Stop înregistrare")
        print("S - Salvează snapshot")
        print("Q - Ieșire")
        print("=================\n")
        
        try:
            while True:
                ret, frame = self.cap.read()
                if not ret:
                    print("⚠️  Nu s-au mai primit frame-uri")
                    break
                
                frame_count += 1
                
                # Înregistrează frame-ul dacă este activ
                if self.is_recording and self.writer:
                    self.writer.write(frame)
                
                # Afișează informații pe frame
                status = "🔴 REC" if self.is_recording else "⏸️  PAUSE"
                cv2.putText(frame, status, (10, 30), 
                           cv2.FONT_HERSHEY_SIMPLEX, 1, 
                           (0, 0, 255) if self.is_recording else (255, 255, 255), 2)
                
                # Afișează frame-ul
                cv2.imshow('RTSP Stream 360° - Vladuceanu Tudor', frame)
                
                # Procesează taste
                key = cv2.waitKey(1) & 0xFF
                if key == ord('q') or key == ord('Q'):
                    break
                elif key == ord('r') or key == ord('R'):
                    if self.is_recording:
                        self.stop_recording()
                    else:
                        self.start_recording()
                elif key == ord('s') or key == ord('S'):
                    self.take_snapshot(frame)
                
        except KeyboardInterrupt:
            print("\n⚠️  Întrerupt de utilizator")
        finally:
            self.cleanup()
            
    def run_headless(self, duration=None):
        """Rulează fără GUI (pentru servere)"""
        self.connect()
        self.start_recording()
        
        start_time = time.time()
        frame_count = 0
        
        try:
            while True:
                ret, frame = self.cap.read()
                if not ret:
                    print("⚠️  Nu s-au mai primit frame-uri")
                    break
                
                if self.writer:
                    self.writer.write(frame)
                
                frame_count += 1
                
                # Afișează progres la fiecare secundă
                if frame_count % int(self.fps) == 0:
                    elapsed = time.time() - start_time
                    print(f"⏱️  Timp: {int(elapsed)}s | Frame-uri: {frame_count}", end='\r')
                
                # Oprește după durata specificată
                if duration and (time.time() - start_time) >= duration:
                    print(f"\n✅ Înregistrare completă ({duration}s)")
                    break
                    
        except KeyboardInterrupt:
            print("\n⚠️  Întrerupt de utilizator")
        finally:
            self.cleanup()
    
    def cleanup(self):
        """Curăță resursele"""
        if self.is_recording:
            self.stop_recording()
        if self.cap:
            self.cap.release()
        cv2.destroyAllWindows()
        print("👋 Închis cu succes")


def main():
    parser = argparse.ArgumentParser(
        description='Recorder pentru stream RTSP 360°',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemple de utilizare:
  %(prog)s --host 192.168.1.100 --preview
  %(prog)s --host localhost --headless --duration 60
  %(prog)s --url rtsp://192.168.1.100:8554/jetson360 --preview
        """
    )
    
    parser.add_argument('--host', default='localhost',
                       help='Hostname sau IP al MediaMTX server (default: localhost)')
    parser.add_argument('--port', default='8554',
                       help='Port RTSP (default: 8554)')
    parser.add_argument('--path', default='jetson360',
                       help='Path stream (default: jetson360)')
    parser.add_argument('--url', help='URL RTSP complet (suprascrie host/port/path)')
    parser.add_argument('--output-dir', default='./recordings',
                       help='Director pentru salvare (default: ./recordings)')
    parser.add_argument('--preview', action='store_true',
                       help='Afișează preview (necesită GUI)')
    parser.add_argument('--headless', action='store_true',
                       help='Rulează fără GUI (pentru servere)')
    parser.add_argument('--duration', type=int,
                       help='Durata înregistrării în secunde (doar headless)')
    
    args = parser.parse_args()
    
    # Construiește URL-ul RTSP
    if args.url:
        rtsp_url = args.url
    else:
        rtsp_url = f"rtsp://{args.host}:{args.port}/{args.path}"
    
    print("=" * 50)
    print("🎥 RTSP Stream Recorder 360°")
    print("   Vladuceanu Tudor")
    print("=" * 50)
    
    recorder = RTSPRecorder(rtsp_url, args.output_dir)
    
    try:
        if args.preview:
            recorder.run_with_preview()
        elif args.headless:
            recorder.run_headless(args.duration)
        else:
            # Default: headless cu Ctrl+C pentru stop
            print("💡 Tip: Folosește --preview pentru GUI sau --headless pentru server")
            recorder.run_headless()
    except Exception as e:
        print(f"\n❌ Eroare: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
