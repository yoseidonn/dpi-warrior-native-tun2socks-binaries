# Tun2socks vv1.16.11 - Linux

## Binaries
This directory contains Linux-specific builds of tun2socks.

### Architectures
- **x86_64/**: 64-bit x86
- **arm64/**: 64-bit ARM
- **armv7/**: 32-bit ARM
- **x86/**: 32-bit x86
- **mips/**: MIPS32
- **mips64/**: MIPS64
- **mips64le/**: MIPS64 little-endian
- **mipsle/**: MIPS32 little-endian
- **ppc64le/**: PowerPC 64-bit little-endian
- **s390x/**: IBM S390x
- **riscv64/**: RISC-V 64-bit

### Linux Usage
```bash
./tun2socks --device fd://3 --proxy socks5://127.0.0.1:10808 --mtu 1500 --dns 8.8.8.8
```
