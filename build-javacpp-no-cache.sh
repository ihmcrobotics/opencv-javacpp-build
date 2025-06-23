#!/bin/sh
docker build -f javacpp.Dockerfile --progress=plain -t opencv-arm64-cuda-cross-javacpp . --no-cache
