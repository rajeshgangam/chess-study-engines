#!/usr/bin/env bash
# Builds Leela Chess Zero (GPL-3.0) for macOS as one universal binary (Apple Silicon + Intel, Metal backend) and
# packages it with network 42850 and the licence: the archive the desktop app downloads when the user picks
# Leela (the Leela project publishes no macOS builds). Needs Xcode command line tools, meson and ninja.
# Usage: tools/lc0/build-macos.sh [out-dir]   -> lc0-v0.32.1-macos-universal.tar.gz and its SHA-256
set -euo pipefail
VERSION=v0.32.1
NET_URL=https://storage.lczero.org/files/networks/3e3444370b9fe413244fdc79671a490e19b93d3cca1669710ffeac890493d198
NET_SHA=ca9a751e614cc753cb38aee247972558cf4dc9d82c5d9e13f2f1f464e350ec23
OUT=$(cd "${1:-.}" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
export MACOSX_DEPLOYMENT_TARGET=12.0
git clone -q --depth 1 --branch "$VERSION" --recurse-submodules https://github.com/LeelaChessZero/lc0.git "$WORK/src"
cat > "$WORK/x86.ini" <<INI
[binaries]
c = ['clang', '-arch', 'x86_64']
cpp = ['clang++', '-arch', 'x86_64']
objc = ['clang', '-arch', 'x86_64']
objcpp = ['clang++', '-arch', 'x86_64']
strip = 'strip'
[host_machine]
system = 'darwin'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
INI
cd "$WORK/src"
meson setup "$WORK/arm" --buildtype=release -Dgtest=false -Db_lto=true
meson setup "$WORK/x86" --cross-file "$WORK/x86.ini" --buildtype=release -Dgtest=false -Db_lto=true
ninja -C "$WORK/arm" && ninja -C "$WORK/x86"
mkdir "$WORK/pkg"
lipo -create "$WORK/arm/lc0" "$WORK/x86/lc0" -output "$WORK/pkg/lc0"
strip -x "$WORK/pkg/lc0"
curl -sL -o "$WORK/pkg/42850.pb.gz" "$NET_URL"
echo "$NET_SHA  $WORK/pkg/42850.pb.gz" | shasum -a 256 -c -
cp COPYING "$WORK/pkg/COPYING"
cat > "$WORK/pkg/README.txt" <<TXT
Leela Chess Zero $VERSION for macOS (universal: Apple Silicon and Intel, Metal backend), with network 42850.
Built unmodified from https://github.com/LeelaChessZero/lc0/tree/$VERSION by tools/lc0/build-macos.sh in
Chess Study. Leela Chess Zero is free software under the GNU GPL version 3 (see COPYING); its source code is
at the address above. Network: https://lczero.org (networks are published by the Leela project).
TXT
# Fixed file order and owner.
tar --uid 0 --gid 0 --uname root --gname root -C "$WORK/pkg" -cf - lc0 42850.pb.gz COPYING README.txt | gzip -n -9 > "$OUT/lc0-$VERSION-macos-universal.tar.gz"
shasum -a 256 "$OUT/lc0-$VERSION-macos-universal.tar.gz"
