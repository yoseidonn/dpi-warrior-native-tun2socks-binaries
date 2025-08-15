# DPI Warrior - tun2socks Native Binaries (LWIP)

This repository hosts scripts and vendored sources to build tun2socks (LWIP) JNI artifacts.

- source/go-tun2socks: Vendored upstream (no submodule)
- source/_upstream/go-tun2socks: Upstream cache (ignored by Git)
- jni_workspaces/tun2socks_lwip: JNI Go wrapper (Android shared library exposing StartTun2Socks, InputTunPacket)
- final_builds/: Build outputs by platform/ABI
- scripts/: Build and publishing helpers

Branching model:
- main: scripts + sources only
- <platform-abi> branches: contain only the artifacts for that target (and a README)

Usage:
- ANDROID_NDK_HOME and API_LEVEL must be set (or via scripts/.secrets)
- ./scripts/build_all.sh android
- ./scripts/init_branches.sh
