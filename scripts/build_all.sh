#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
WORK_DIR="$REPO_ROOT"
UPSTREAM_DIR="$REPO_ROOT/source/_upstream"
FINAL_DIR="$REPO_ROOT/final_builds"
ANDROID_NDK_HOME=${ANDROID_NDK_HOME:-${ANDROID_NDK:-}}
API_LEVEL=${API_LEVEL:-26}
export GOTOOLCHAIN=local

SECRETS_FILE="$REPO_ROOT/scripts/.secrets"
if [[ -f "$SECRETS_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$SECRETS_FILE"
else
  echo "⚠️  secrets file missing: $SECRETS_FILE (will rely on environment)"
fi

missing=()
[[ -z "${ANDROID_NDK_HOME:-}" ]] && missing+=("ANDROID_NDK_HOME")
[[ -z "${API_LEVEL:-}" ]] && echo "ℹ️  API_LEVEL not set; using default ${API_LEVEL}" || true
if ((${#missing[@]} > 0)); then
  echo "❌ Missing required variables: ${missing[*]}"
  exit 1
fi

clone_or_update() {
  mkdir -p "$UPSTREAM_DIR"
  if [[ ! -d "$UPSTREAM_DIR/go-tun2socks/.git" ]]; then
    rm -rf "$UPSTREAM_DIR/go-tun2socks"
    git clone https://github.com/eycorsican/go-tun2socks.git "$UPSTREAM_DIR/go-tun2socks"
  else
    (cd "$UPSTREAM_DIR/go-tun2socks" && git fetch --all && git reset --hard origin/master || git reset --hard origin/main)
  fi
  # Vendorize upstream (no .git)
  rsync -a --delete --exclude ".git" "$UPSTREAM_DIR/go-tun2socks/" "$REPO_ROOT/source/go-tun2socks/"
}

build_android() {
  local src="$REPO_ROOT/jni_workspaces/tun2socks_lwip"
  [[ -d "$ANDROID_NDK_HOME" ]] || { echo "❌ ANDROID_NDK_HOME not set or invalid: $ANDROID_NDK_HOME"; exit 1; }
  mkdir -p "$FINAL_DIR/android/arm64-v8a" "$FINAL_DIR/android/armeabi-v7a" "$FINAL_DIR/android/x86_64"
  pushd "$src" >/dev/null
  build_one() {
    local abi="$1" goarch="$2" cc="$3" out="$4"
    env GOOS=android GOARCH="$goarch" CGO_ENABLED=1 CC="$cc" go build -v -trimpath -buildmode=c-shared -o "$out/libtun2socks.so" .
  }
  build_one arm64-v8a arm64 "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android${API_LEVEL}-clang" "$FINAL_DIR/android/arm64-v8a"
  build_one armeabi-v7a arm "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi${API_LEVEL}-clang" "$FINAL_DIR/android/armeabi-v7a"
  build_one x86_64 amd64 "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android${API_LEVEL}-clang" "$FINAL_DIR/android/x86_64"
  popd >/dev/null
  # Copy to frontend jniLibs if exists
  jni_target="$REPO_ROOT/../dpi-warrior-frontend/android/app/src/main/jniLibs"
  if [ -d "$jni_target" ]; then
    mkdir -p "$jni_target/arm64-v8a" "$jni_target/armeabi-v7a" "$jni_target/x86_64"
    cp -f "$FINAL_DIR/android/arm64-v8a/libtun2socks.so" "$jni_target/arm64-v8a/" 2>/dev/null || true
    cp -f "$FINAL_DIR/android/armeabi-v7a/libtun2socks.so" "$jni_target/armeabi-v7a/" 2>/dev/null || true
    cp -f "$FINAL_DIR/android/x86_64/libtun2socks.so" "$jni_target/x86_64/" 2>/dev/null || true
  fi
}

case "${1:-all}" in
  all)
    clone_or_update
    build_android
    "$REPO_ROOT/scripts/init_branches.sh"
    ;;
  android)
    clone_or_update
    build_android
    "$REPO_ROOT/scripts/init_branches.sh"
    ;;
  *) echo "Usage: $0 {all|android}" ;;
 esac 
