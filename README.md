# opencv-javacpp-build
IHMC Robotics javacpp-presets/opencv builds

## Versions
| Platform              | JavaCPP version | OpenCV version | CUDA version | cuDNN version | highgui (imshow) enabled |
|-----------------------|-----------------|----------------|--------------|---------------|--------------------------|
| L4T Orin (CUDA)       | 1.5.11          | 4.10.0         | 12.6         | 9.3           | No                       |
| Linux arm64           | 1.5.11          | 4.10.0         |              |               | No                       |
| Linux x86_64 (CUDA)   | 1.5.11          | 4.10.0         | 12.9         | 9.9           | Yes                      |
| Linux x86_64          | 1.5.11          | 4.10.0         |              |               | Yes                      |
| Windows x86_64 (CUDA) | 1.5.11          | 4.10.0         | 12.9         | 9.9           | Yes                      |
| Windows x86_64        | 1.5.11          | 4.10.0         |              |               | Yes                      |

## Patches
Patches needed for OpenCV 4.10.0 with CUDA 12.9

- https://github.com/opencv/opencv/pull/27522
- https://github.com/opencv/opencv/pull/27288

## Building Notes
Windows - You must shorten the build path as much as possible (e.g. clone this repo into `C:\a`). Otherwise you'll get a CMake issue where it'll run the configuration in a loop.

Windows - You must install cuDNN using the method found in the windows-x86_64 GitHub workflow. Using the cuDNN installer will not work, CMake will not find it.
