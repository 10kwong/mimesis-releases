# 映題 Mimesis — public release feed

This repository contains **only** signed release artifacts, installers and update manifests for
映題 Mimesis. It contains no application source, no teacher data, no API keys and no signing keys.

- Update feed (macOS Apple Silicon): https://10kwong.github.io/mimesis-releases/mac-arm64/latest.json
- Update feed (Windows x64): https://10kwong.github.io/mimesis-releases/windows-x64/latest.json
- Releases: https://github.com/10kwong/mimesis-releases/releases

Every manifest is signed with the ed25519 release key embedded in the app. The app refuses a
manifest whose signature, platform, version or SHA-256 does not match.
