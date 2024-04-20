#!/bin/bash

set -e

# source /data/.env
source .env

# whisper=$(which whisper)
whisper="/Users/pascal/Work/Code/whisper.cpp/main"

model="/Users/pascal/Work/Code/whisper.cpp/models/ggml-large.bin"

job=$(curl -s -H "Accept: application/json" \
    -H "Authorization: Bearer $XDIO_API_TOKEN" \
    "$XDIO_API_URL/v2/whisper/job/$1"
)

echo $job | jq;

len=$(echo "${job}" | jq -r 'length')

if [ "$len" -gt 0 ]; then

    hash=$(echo "${job}" | jq -r '.job.hash')
    mode=$(echo "${job}" | jq -r '.job.mode')
    opts=$(echo "${job}" | jq -r '.job.opts')
    info=$(echo "${job}" | jq -r '.job.info')
    audio=$(echo "${job}" | jq -r '.job.audio')

    # Todo: Fix HLS stream (.m3u8)
    curl -sL "$audio" > "xdio-${hash}.mp4"
    ffmpeg -y -i "xdio-${hash}.mp4" -ar 16000 -ac 1 -c:a pcm_s16le "xdio-${hash}.wav"

    time $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -bs 5 -et 2.8 -mc 64

    # Done.
    task=$(curl -s -H "Accept: application/json" \
        -H "Authorization: Bearer $XDIO_API_TOKEN" \
        -F "vtt=@xdio-$hash.vtt" \
        -F "hash=$hash" \
        "$XDIO_API_URL/v2/whisper/done"
    )

    echo $task;

    rm "xdio-${hash}.mp4"
    rm "xdio-${hash}.wav"
    rm "xdio-${hash}.vtt"

fi

