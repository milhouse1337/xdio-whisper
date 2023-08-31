#!/bin/bash

# docker build -t milhouse1337/xdio-whisper .
# docker build --platform=linux/arm64/v8 -t milhouse1337/xdio-whisper .
# docker push milhouse1337/xdio-whisper

docker buildx build --push --platform linux/amd64,linux/arm64 --tag milhouse1337/xdio-whisper .
