#!/bin/bash

set -e

# source /data/.env
source .env

# whisper=$(which whisper)
whisper="/Users/pascal/Work/Code/whisper.cpp/main"

# model="/whisper/models/ggml-large.bin"
# model="/Users/pascal/Work/Code/whisper.cpp/models/ggml-french-v3.bin"
# model="/Users/pascal/Work/Code/whisper.cpp/models/ggml-large-v2.bin"
model="/Users/pascal/Work/Code/whisper.cpp/models/ggml-large.bin"
# model="/Users/pascal/Work/Temp/ggml-french.bin"
# model="/Users/pascal/Work/Temp/ggml-model.bin"
# model="/Users/pascal/Work/Temp/ggml-large.bin"

# -bs 5
# -nf -bs 5
# $whisper -l fr -m $model -f "/Users/pascal/niquet1.wav" -of "niquet1" -ovtt -pc -di
# exit 0;

while true; do

    next=$(curl -s -H "Accept: application/json" \
        -H "Authorization: Bearer $XDIO_API_TOKEN" \
        "$XDIO_API_URL/v2/whisper/work"
    )

    echo $next | jq;

    len=$(echo "${next}" | jq -r 'length')

    if [ "$len" -gt 0 ]; then

        hash=$(echo "${next}" | jq -r '.job.hash')
        mode=$(echo "${next}" | jq -r '.job.mode')
        opts=$(echo "${next}" | jq -r '.job.opts')
        info=$(echo "${next}" | jq -r '.job.info')
        audio=$(echo "${next}" | jq -r '.job.audio')

        # Todo: Fix HLS stream (.m3u8)
        curl -sL "$audio" > "xdio-${hash}.mp4"
        ffmpeg -y -i "xdio-${hash}.mp4" -ar 16000 -ac 1 -c:a pcm_s16le "xdio-${hash}.wav"

        # Fine-tuning with: -bs 4 -bo 4
        # time $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -bs 6 -bo 6
        time $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -bs 5 -et 2.8 -mc 64
        # $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -et 2.8
        # time $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc
        # $whisper -l fr -m $model -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -ml 80

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

    sleep 30

done
