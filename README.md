# Chess Study engine builds

Engine binaries that the Chess Study desktop app downloads when the user chooses them. The app checks each
download against a SHA-256 digest pinned in its source.

## Leela Chess Zero v0.32.1 for macOS

`lc0-v0.32.1-macos-universal.tar.gz` (release `lc0-v0.32.1`): one universal binary (Apple Silicon and Intel,
Metal backend) built unmodified from https://github.com/LeelaChessZero/lc0/tree/v0.32.1 by `build-macos.sh`,
with network 42850 from https://lczero.org and the licence. The Leela project publishes no macOS builds.

SHA-256: `2d357aa6dfebb69249103c167e03c017e048367f1dbd0a5bafa9ce3e0bc7b6b9`

Leela Chess Zero is free software under the GNU General Public License version 3 (see `COPYING`). Its
complete source code is at https://github.com/LeelaChessZero/lc0 (tag v0.32.1); this repository adds only
the build script. Networks are published by the Leela Chess Zero project.
