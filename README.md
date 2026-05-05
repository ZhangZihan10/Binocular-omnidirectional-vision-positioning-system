# High-Precision Target Positioning via Multi-View Fisheye Cameras and Structured Light

This repository contains the simulation environment and algorithm scripts for achieving high-precision target positioning. The system integrates a Unity3D virtual simulation platform with MATLAB image processing and positioning algorithms, utilizing multi-view fisheye cameras and linear structured lighting.

## 🔗 Project Resources

* **Video Demonstration:** [Watch the system in action on Bilibili](https://www.bilibili.com/video/BV1Jz9RBXEKj/?spm_id_from=333.1387.homepage.video_card.click)
* **Published Paper:** [Read the full research paper on MDPI](https://www.mdpi.com/1424-8220/25/20/6485)

## 🏗️ System Architecture

The project is divided into two main components: the Unity3D simulation environment and the MATLAB processing backend.

### 1. Unity3D Simulation

The Unity scene simulates the physical environment, including two 180-degree fisheye cameras, a wire laser emitter, and test objects such as cubes and spheres. It relies on three core scripts:

* **`ImageCapture.cs`**: Mounted on the cameras to save rendered images as PNGs and transmit them to MATLAB in real-time via the TCP protocol.
* **`LaserController.cs`**: Simulates real-line structured light projection by controlling the switch and rotation angle of the laser emitter, allowing for dynamic adjustment of the laser plane.
* **`UIManager.cs`**: Handles user interactions, triggering events to capture calibration images, switch target shapes, or start the localization processes.

### 2. MATLAB Image Processing & Localization

The MATLAB backend receives the image data and calculates the 3D spatial coordinates of the target using either monocular or binocular methods.

* **Monocular Positioning (`mono_localization.m`)**: Calculates 3D coordinates using an image from a single camera combined with the laser plane equation.
* **Binocular Positioning (`binocular_localization.m`)**: Directly calculates 3D coordinates through triangulation using images from both left and right cameras. This method relies on image disparity and is not sensitive to errors in the laser plane equation, yielding significantly higher accuracy.

**Core Algorithm Sub-functions:**
* `extract_laser_center.m`: Performs sub-pixel extraction of the laser stripe center utilizing the Hessian matrix (Steger algorithm).
* `cluster_points.m`: Applies DBSCAN clustering based on Euclidean distance to denoise the point cloud, retaining the largest cluster to determine the final average coordinates.
* `triangulate.m`: Used in the binocular setup to perform triangulation on matching points based on external parameters.

> **Note:** Within the broader scope of this computer vision pipeline, convolutional neural networks (CNNs) are strictly utilized for target semantic segmentation to isolate the object of interest, rather than for performing the direct localization calculations.

## ⚙️ Setup and Communication

For the system to function correctly in real-time, the Unity platform and the MATLAB scripts communicate via TCP.

1. Ensure the Unity server script is configured to match the MATLAB client variable.
2. Both systems must be set to communicate over **Port 55019** (`127.0.0.1`).

## 💻 System Requirements

The algorithms and processing pipelines in this repository have been developed and tested on an **Intel Core Ultra 9** processor to ensure optimal performance during real-time TCP transmission and point cloud clustering.

## 📝 Acknowledgements

This software project, *Single-Snapshot Calibration and 3D Reconstruction*, was developed by Zihan Zhang in collaboration with Ivan Kholodilin.

This research is supported by the Russian Science Foundation under grant number **25-79-10376**.