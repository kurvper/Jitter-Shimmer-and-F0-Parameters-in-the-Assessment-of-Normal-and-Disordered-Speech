# Jitter, Shimmer, and F0 Analysis of Normal and Disordered Speech

## Description

This MATLAB project analyzes speech recordings by calculating three commonly used voice parameters:

* **Fundamental Frequency (F0)**
* **Jitter**
* **Shimmer**

The program compares recordings of **normal** and **disordered** speech and visualizes the results using 2D and 3D plots.

## Requirements

* MATLAB
* Signal Processing Toolbox

## How to Run

1. Place the folders with .wav files: `prawidłowa` and `patologiczna` in the project directory.
2. Open `analysis.m` in MATLAB.
3. Run the script.

The program automatically searches all `.wav` files in both folders and their subfolders.

## Output

The script generates:

* A table containing Jitter, Shimmer, and F0 values for each recording.
* A 2D scatter plot (Jitter vs. Shimmer).
* A 3D scatter plot (Jitter, Shimmer, and F0) comparing normal and disordered speech.
