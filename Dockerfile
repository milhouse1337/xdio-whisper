FROM ubuntu:22.04
LABEL maintainer "Pascal Meunier @milhouse1337"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y build-essential git wget curl jq g++ make libsdl2-dev alsa-utils ffmpeg

RUN git clone https://github.com/ggerganov/whisper.cpp.git /whisper
RUN cd /whisper && make main stream quantize
RUN cp /whisper/main /usr/bin/whisper && \
    cp /whisper/stream /usr/bin/stream && \
    cp /whisper/quantize /usr/bin/quantize

RUN cd /whisper && ./models/download-ggml-model.sh large-v3

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y nodejs

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /data

CMD ["npm", "run", "work"]
