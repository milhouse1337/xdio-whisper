FROM debian:latest
LABEL maintainer "Pascal Meunier @milhouse1337"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y git wget curl jq g++ make libsdl2-dev alsa-utils ffmpeg

RUN git clone https://github.com/ggerganov/whisper.cpp.git /whisper
RUN cd /whisper && ./models/download-ggml-model.sh large
RUN cd /whisper && make main stream quantize
RUN cp /whisper/main /usr/bin/whisper && \
    cp /whisper/stream /usr/bin/stream && \
    cp /whisper/quantize /usr/bin/quantize

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./work.sh /root/work.sh

WORKDIR /data

CMD ["/root/work.sh"]
