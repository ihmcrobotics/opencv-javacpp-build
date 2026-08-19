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
Linux arm64 / L4T — Ubuntu 22.04's GCC 11 emits outline-atomics (`__aarch64_ldadd4_acq_rel`).
Java cannot resolve those helpers when it `dlopen`s the JNI `.so` on the robot. Both ARM
Dockerfiles wrap `aarch64-linux-gnu-gcc/g++` with `-mno-outline-atomics`. Rebuild L4T Orin
after changing that, publish the new dated artifact, and delete `~/.javacpp/cache` on the
robot so it does not keep the old `linux-arm64-gpu` jar.

Windows - You must shorten the build path as much as possible (e.g. clone this repo into `C:\a`). Otherwise you'll get a CMake issue where it'll run the configuration in a loop.

Windows - You must install cuDNN using the method found in `.github/workflows/build.yml`. Using the cuDNN installer will not work, CMake will not find it.

GitHub: run **Build OpenCV JavaCPP** (`workflow_dispatch`) and pass `version_date` (YYYYMMDD). Each platform uploads a Maven-layout artifact.
