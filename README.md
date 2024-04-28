# Xdio - Whisper

This is a simple `worker` based on [BullMQ](https://docs.bullmq.io/) to dispatch translations jobs. You can contribute to our translation efforts by installing this project on your computer. It's similar to SETI@home, but instead of searching for extraterrestrial signals, you'll help us translate the entire Xdio database. 👽

## Requirements

- MacOS (with Apple Silicon)
- Node.js (20+)
- Brew

## Setup

Install a few dependencies with [Brew](https://brew.sh/).

```bash
brew install curl ffmpeg jq wget
```

Clone this repo.

```bash
git clone https://github.com/milhouse1337/xdio-whisper.git
cd xdio-whisper
```

Fetch [Whisper](https://github.com/ggerganov/whisper.cpp) (as submodule), download the model and build it.

```bash
git submodule update --init --remote --recursive
cd whisper
bash ./models/download-ggml-model.sh large-v3
make
cd ..
```

Install the Node dependencies with npm.

```bash
npm ci
```

Copy the default `.env` file and update it.

```bash
cp .env.example .env
```

You can now update the `.env` file in your favorite editor. 

```bash
vi .env
# code .env
# zed .env
```

Please contact us on [Discord](https://discord.gg/A6tHyATaw7) if you need help with the API keys.

## Launch the worker 🚀

To start the process.

```bash
npm run work
```

## Docker

WIP: The build fails for now, we are working on it.

```bash
# docker run -it --rm -v "$(pwd)":/data:rw milhouse1337/xdio-whisper
```
