# Tun2socks vv1.16.11 - Native Builds

## Overview
This repository contains native builds of [xjasonlyu/tun2socks](https://github.com/xjasonlyu/tun2socks) for all major platforms and architectures.

## Supported Platforms

### 🤖 Android
- **arm64-v8a**: ARM64 with .so and executable
- **armeabi-v7a**: ARMv7 with .so and executable  
- **x86_64**: x86_64 with .so and executable
- **x86**: x86 with .so and executable

### 🍎 iOS
- **arm64**: ARM64 executable
- **x86_64**: x86_64 executable (for simulator)

### 🖥️ macOS
- **arm64**: Apple Silicon (M1/M2)
- **x86_64**: Intel Mac

### 🪟 Windows
- **x64**: 64-bit Windows
- **x86**: 32-bit Windows

### 🐧 Linux
- **x86_64**: 64-bit x86
- **arm64**: 64-bit ARM
- **armv7**: 32-bit ARM
- **x86**: 32-bit x86
- **mips**: MIPS32
- **mips64**: MIPS64
- **mips64le**: MIPS64 little-endian
- **mipsle**: MIPS32 little-endian
- **ppc64le**: PowerPC 64-bit little-endian
- **s390x**: IBM S390x
- **riscv64**: RISC-V 64-bit

## Usage

### Android (.so files)
```kotlin
// Load the shared library
System.loadLibrary("tun2socks")

// Use with file descriptor approach
val command = arrayOf(
    "/path/to/libtun2socks.so",
    "--device", "fd://$tunFd",
    "--proxy", "socks5://127.0.0.1:10808",
    "--mtu", "1500",
    "--dns", "8.8.8.8"
)
```

### Other Platforms
```bash
./tun2socks --device fd://3 --proxy socks5://127.0.0.1:10808 --mtu 1500 --dns 8.8.8.8
```

## Parameters
- `--device fd://N`: Use file descriptor N for TUN interface
- `--proxy socks5://host:port`: SOCKS5 proxy server
- `--mtu N`: Maximum Transmission Unit
- `--dns host`: DNS server

## Download
Each platform/architecture has its own branch for easy downloading:
- `android-arm64-v8a`: Android ARM64 builds
- `linux-x86_64`: Linux x86_64 builds
- etc.

## License
MIT License - see [xjasonlyu/tun2socks](https://github.com/xjasonlyu/tun2socks) for details.
