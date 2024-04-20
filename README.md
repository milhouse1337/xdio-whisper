# Xdio - Whisper

## Requirements

- MacOS (with Apple Silicon)
- Node.js (20+)
- Brew

## Setup

Install a few dependencies with Brew.

```bash
brew install curl ffmpeg jq wget
```

Install Whisper (as submodule) and download the model.

```bash
git submodule update --init --remote --recursive
cd whisper
bash ./models/download-ggml-model.sh large-v3
make
```

Add the `.env` file and update it.

```bash
cp .env.example .env
```

You can update the file in your editor.

```bash
vi .env
# code .env
# zed .env
```

## Launch

To start the process.

```bash
./work.sh
```

## Docker

WIP: The build fails for now.

```bash
docker run -it --rm -v "$(pwd)":/data:rw milhouse1337/xdio-whisper
```
