#!/bin/bash

set -e

# source /data/.env
source .env

whisper="./whisper/main"
model="./whisper/models/ggml-large-v3.bin"

# whisper="/whisper/main"
# model="/whisper/models/ggml-large-v3.bin"

job=$(curl -s -H "Accept: application/json" \
    -H "Authorization: Bearer $XDIO_API_TOKEN" \
    "$XDIO_API_URL/v2/whisper/job/$1"
)

echo $job | jq;

len=$(echo "${job}" | jq -r 'length')

if [ "$len" -gt 0 ]; then

    hash=$(echo "${job}" | jq -r '.job.hash')
    opts=$(echo "${job}" | jq -r '.job.opts')
    info=$(echo "${job}" | jq -r '.job.info')
    audio=$(echo "${job}" | jq -r '.job.audio')

    if [[ "$audio" == *".m3u8"* ]]; then
        ffmpeg -y -loglevel error -i "$audio" -map p:0 -c copy "xdio-${hash}.mp4"
    else
        curl -sL "$audio" > "xdio-${hash}.mp4"
    fi

    ffmpeg -y -loglevel error -i "xdio-${hash}.mp4" -ar 16000 -ac 1 -c:a pcm_s16le "xdio-${hash}.wav"

    time $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -pp -bs 5 -et 2.8 -mc 64

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
