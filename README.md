# Wazza

An offline, on-device chat app for Android. Download a GGUF model once, then chat with it locally — no account, no API key, no server.

## What it does

- **Local inference** — runs GGUF models on your phone via llama.cpp (`llama_flutter_android`).
- **Model catalog** — browse and download a handful of small models in-app (SmolLM2, Qwen2.5, Gemma 2, Phi-3.5/4, Llama 3.2 3B).
- **Bring your own model** — the app scans its `models` and `shared_models` folders for `.gguf` files and adds them automatically.
- **Chat** — streaming replies, markdown rendering, copy, per-chat history, and a model switcher.
- **Voice** — speech-to-text input and text-to-speech for replies.
- **Encrypted storage** — chats and messages are stored in a local encrypted database (Drift + `encrypted_drift`).
- **Monochrome UI** — black-and-white theme with light and dark modes.

## Platform

Android only for now. The inference backend is Android-specific, so iOS and desktop are not supported.

## Getting started

### From a release
1. Get the latest `app-release.7z` from Releases.
2. Extract and install the APK.
3. Open Wazza, download a model, and start chatting.

### From source
```bash
flutter pub get
flutter run            # on a connected Android device
```

Requires Flutter 3.35+ and an Android device or emulator. The first build compiles the native llama.cpp library, so it takes a while.

## Models

Models are downloaded from their Hugging Face URLs into the app's documents directory. Bigger models are slower and use more RAM; pick based on your device:

| Size | Examples | Notes |
| --- | --- | --- |
| Under 500 MB | SmolLM2 135M/360M, Qwen2.5 0.5B | Fast, good for testing |
| 0.5–1.5 GB | SmolLM2 1.7B, Qwen2.5 1.5B, Gemma 2 2B | Good everyday balance |
| 1.5–3 GB | Phi-3.5 Mini, Qwen2.5 3B, Llama 3.2 3B | Better quality, heavier |
| 3 GB+ | Phi-4 Mini, Qwen2.5 7B | Needs a capable device |

## Tech stack

- **Flutter** + **Riverpod** for state management
- **go_router** for navigation
- **Drift** (encrypted) for storage
- **llama_flutter_android** for local inference

## Development

```bash
dart analyze     # static analysis
flutter test     # unit tests
```

## Status

Early-stage and Android-only. Performance and supported models depend on your device's RAM and chip.

## License

No license file is included yet.
