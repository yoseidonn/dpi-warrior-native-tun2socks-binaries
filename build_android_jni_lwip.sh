#!/bin/bash

set -e

BUILD_DIR="lwip_workspace"
JNI_TARGET_DIR="../../frontend/android/app/src/main/jniLibs"
FINAL_BUILDS_DIR="final-builds/android"
API_LEVEL=${API_LEVEL:-26}

if [ -z "$ANDROID_NDK_HOME" ]; then
  echo "❌ ANDROID_NDK_HOME not set"; exit 1
fi
NDK_PATH="$ANDROID_NDK_HOME"

if [ ! -d "$BUILD_DIR" ]; then echo "❌ $BUILD_DIR missing"; exit 1; fi
if [ ! -d "$JNI_TARGET_DIR" ]; then echo "❌ $JNI_TARGET_DIR missing"; exit 1; fi
mkdir -p "$FINAL_BUILDS_DIR/arm64-v8a" "$FINAL_BUILDS_DIR/armeabi-v7a" "$FINAL_BUILDS_DIR/x86_64"

echo "=== Building LWIP-based libtun2socks.so ==="

cd "$BUILD_DIR"

build_one() {
  local abi="$1" goarch="$2" ccbin="$3"
  local outdir="../$JNI_TARGET_DIR/$abi"
  mkdir -p "$outdir"
  export GOOS=android GOARCH="$goarch" CGO_ENABLED=1 CC="$ccbin"
  go clean -cache -testcache
  go build -a -v -trimpath -buildmode=c-shared -o "$outdir/libtun2socks.so" .
  cp -f "$outdir/libtun2socks.so" "../$FINAL_BUILDS_DIR/$abi/"
  nm -D --defined-only "$outdir/libtun2socks.so" | grep -E "StartTun2Socks|InputTunPacket|IsTun2SocksRunning|GetTun2SocksStatus|GetVersion" || true
}

# arm64-v8a
CC_ARM64="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$API_LEVEL-clang"
if [ -x "$CC_ARM64" ]; then
  echo "-- arm64-v8a with $CC_ARM64"
  build_one arm64-v8a arm64 "$CC_ARM64"
else
  echo "⚠️  missing $CC_ARM64"
fi
# armeabi-v7a
CC_ARMV7="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi$API_LEVEL-clang"
if [ -x "$CC_ARMV7" ]; then
  echo "-- armeabi-v7a with $CC_ARMV7"
  build_one armeabi-v7a arm "$CC_ARMV7"
else
  echo "⚠️  missing $CC_ARMV7"
fi
# x86_64
CC_X86_64="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android$API_LEVEL-clang"
if [ -x "$CC_X86_64" ]; then
  echo "-- x86_64 with $CC_X86_64"
  build_one x86_64 amd64 "$CC_X86_64"
else
  echo "⚠️  missing $CC_X86_64"
fi

cd - >/dev/null

echo "🎉 LWIP libtun2socks builds complete" 