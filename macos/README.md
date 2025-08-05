# Tun2socks vv1.16.11 - macOS

## Binaries
This directory contains macOS-specific builds of tun2socks.

### Architectures
- **arm64/**: Apple Silicon (M1/M2)
- **x86_64/**: Intel Mac

### macOS Usage
```bash
./tun2socks --device fd://3 --proxy socks5://127.0.0.1:10808 --mtu 1500 --dns 8.8.8.8
```
