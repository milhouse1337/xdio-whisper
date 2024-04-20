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

Clone this repo.

```bash
git clone https://github.com/milhouse1337/xdio-whisper.git
cd xdio-whisper
```

Install Whisper (as submodule) and download the model.

```bash
git submodule update --init --remote --recursive
cd whisper
bash ./models/download-ggml-model.sh large-v3
make
cd ..
```

Install node dependencies.

```bash
npm ci
```

Copy the default `.env` file and update it.

```bash
cp .env.example .env
```

You can update the file in your favorite editor. 

```bash
vi .env
# code .env
# zed .env
```

Please contact us on [Discord](https://discord.gg/A6tHyATaw7) if you need help with the API keys.

## Launch

To start the process.

```bash
./work.sh
```

## Docker

WIP: The build fails for now, we are working on it.

```bash
# docker run -it --rm -v "$(pwd)":/data:rw milhouse1337/xdio-whisper
```
