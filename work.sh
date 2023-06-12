#!/bin/bash

set -e

source /data/.env

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
        whisper -l fr -m /whisper/models/ggml-large.bin -f "xdio-${hash}.wav" -of "xdio-${hash}" -ovtt -pc -bs 4 -bo 4

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

    sleep 300

done
