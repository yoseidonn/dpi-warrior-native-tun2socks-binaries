# Tun2socks vv1.16.11 - iOS

## Binaries
This directory contains iOS-specific builds of tun2socks.

### Architectures
- **arm64/**: ARM64 executable (iPhone/iPad)
- **x86_64/**: x86_64 executable (iOS Simulator)

### iOS Usage
```swift
// Use with file descriptor approach
let process = Process()
process.executableURL = URL(fileURLWithPath: "/path/to/tun2socks")
process.arguments = [
    "--device", "fd://\(tunFd)",
    "--proxy", "socks5://127.0.0.1:10808",
    "--mtu", "1500",
    "--dns", "8.8.8.8"
]
```
