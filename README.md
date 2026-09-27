VoxTerra AI Mine Safety, Rescue Control & Rover Simulation Suite
Welcome to the VoxTerra project repository. VoxTerra is a multi-layered, AI-powered system designed for autonomous underground mine safety, hazard detection, real-time telemetry analytics, and multi-rover mesh-relay communication.

This repository contains the complete simulation prototypes, 3D sensor fusion HUDs, mesh network algorithms, and links to the full production web application.

🚀 Live Demo & Web App
🌐 Production Web Application: voxterra-mine-rescue.onrender.com

⚙️ Repository Source: Simulation and control nodes for VoxTerra scout rovers.




1. Production Control Platform (voxterra-mine-rescue.onrender.com)
   The centralized web portal for real-time mine operations and emergency response management:Interactive 20×20 Mine Safety Map: Sector-based thermal sweeps, hazard mapping (Safe, Elevated Gas, Critical, Gas Source), and trapped survivor tracking.
   15-Stage Analysis Pipeline: MATLAB-inspired analytical workflow computing AI risk intelligence and automated decision support scores.
   Temporal Trend Analysis: Multi-visit gas concentration comparisons (Visit 1 vs Visit 2) for predictive threat modeling.Operations & Audit Logging: Priority alert dispatches and immutable mission event logging for active field units.
   
3. 3D Rover Sensor Fusion & Telemetry (voxterra-rover-simulation.html)
   An interactive, browser-based 3D HUD interface simulating on-rover perception systems:3D LiDAR Tunnel Point Cloud: Real-time WebGL/Three.js rendering of curved underground mine geometry using dynamic color spectrums.
   Multi-Camera Stream Overlay: Front RGB optical stream, LWIR thermal infrared feed, and top-down LiDAR point-cloud viewports.
     Environmental & IMU Gauges: Live telemetry monitoring for CH_4, CO, O_2, H_2S, ambient temperature, flood depth, and 3-axis IMU orientation (Pitch, Roll, Yaw).


   
5. Multi-Rover Mesh Relay Network (voxterra-mesh-sim.html)
   A dynamic 2D graph simulation demonstrating ad-hoc, hop-by-hop wireless mesh networking inside mine shafts:Autonomous Routing: Calculates communication range radiuses (R_{COMM} = 150Px) between active field rovers (R1–R4) and the Surface Gateway (GW) using Breadth-First Search (BFS) graph traversal.Dynamic Fault Tolerance: Interactive rockfall simulation disables intermediate relay nodes (e.g., R2), prompting roaming bridge units ($R5$) to automatically bridge broken links and prevent stale-data dropouts.


   
7. 📁 Repository Structure
Plaintext
├── voxterra-rover-simulation.html  # 3D WebGL HUD, LiDAR point cloud & multi-sensor simulation
├── voxterra-mesh-sim.html          # 2D Canvas-based dynamic mesh relay simulation & routing
└── README.md                       # Project documentation
Quick Start (Local Execution)Both simulation modules are standalone client-side HTML5/JS applications requiring no additional build toolchain:Clone the Repository:Bashgit clone https://github.com/malik-2007/voxterra-rover-simulation.git
cd voxterra-rover-simulation
Run in Browser:Double-click voxterra-mesh-sim.html to open the mesh relay routing simulation.Double-click voxterra-rover-simulation.html to launch the 3D LiDAR HUD telemetry view.🎮 Interface ControlsMesh Network (voxterra-mesh-sim.html):Pause / Play: Halts or resumes patrol cycles.Speed Slider: Adjusts trajectory speeds ($0.5\times$ to $3.0\times$).Simulate Rockfall: Disables Node $R2$ to force real-time network path re-computation.3D HUD (voxterra-rover-simulation.html):TRIGGER EMERGENCY: Injects critical methane spikes and thermal human detection alerts into the telemetry stream.
