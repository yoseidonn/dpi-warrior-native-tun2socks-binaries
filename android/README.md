# Tun2socks vv1.16.11 - Android

## Binaries
This directory contains Android-specific builds of tun2socks.

### Architectures
- **arm64-v8a/**: ARM64 with .so and executable files
- **armeabi-v7a/**: ARMv7 with .so and executable files
- **x86_64/**: x86_64 with .so and executable files
- **x86/**: x86 with .so and executable files

### Android Usage
```kotlin
// For .so files (recommended)
System.loadLibrary("tun2socks")

// For executable files
val process = ProcessBuilder(
    "/path/to/tun2socks",
    "--device", "fd://$tunFd",
    "--proxy", "socks5://127.0.0.1:10808",
    "--mtu", "1500",
    "--dns", "8.8.8.8"
).start()
```
