package main

/*
#cgo LDFLAGS: -llog
#include <android/log.h>
static void alog(const char* msg) { __android_log_write(ANDROID_LOG_INFO, "Tun2Socks-LWIP", msg); }
*/
import "C"

import (
	"net"
	"os"
	"strings"
	"sync/atomic"
	"time"
	"unsafe"

	core "github.com/eycorsican/go-tun2socks/core"
	socks "github.com/eycorsican/go-tun2socks/proxy/socks"
)

var (
	started    int32
	outTunFile *os.File
)

//export StartTun2Socks
func StartTun2Socks(tunFd C.int, proxy *C.char, mtu C.int) C.int {
	if !atomic.CompareAndSwapInt32(&started, 0, 1) {
		return 1 // already running
	}
	// Set output function: write processed packets back to TUN
	outTunFile = os.NewFile(uintptr(tunFd), "tun")
	core.RegisterOutputFn(func(data []byte) (int, error) {
		if outTunFile == nil {
			return 0, os.ErrClosed
		}
		n, err := outTunFile.Write(data)
		return n, err
	})
	// Configure SOCKS outbound
	p := C.GoString(proxy)
	addr := p
	if strings.HasPrefix(addr, "socks5://") {
		addr = strings.TrimPrefix(addr, "socks5://")
	}
	proxyAddr, err := net.ResolveTCPAddr("tcp", addr)
	if err != nil {
		C.alog(C.CString("LWIP invalid proxy address"))
		return -1
	}
	proxyHost := proxyAddr.IP.String()
	proxyPort := uint16(proxyAddr.Port)
	core.RegisterTCPConnHandler(socks.NewTCPHandler(proxyHost, proxyPort))
	core.RegisterUDPConnHandler(socks.NewUDPHandler(proxyHost, proxyPort, 60*time.Second))
	C.alog(C.CString("LWIP Start complete"))
	return 0
}

//export StopTun2Socks
func StopTun2Socks() C.int {
	if !atomic.CompareAndSwapInt32(&started, 1, 0) {
		return 1 // not running
	}
	core.RegisterTCPConnHandler(nil)
	core.RegisterUDPConnHandler(nil)
	if outTunFile != nil {
		_ = outTunFile.Close()
		outTunFile = nil
	}
	return 0
}

//export IsTun2SocksRunning
func IsTun2SocksRunning() C.int {
	if atomic.LoadInt32(&started) == 1 {
		return 1
	}
	return 0
}

//export GetTun2SocksStatus
func GetTun2SocksStatus() *C.char {
	if atomic.LoadInt32(&started) == 1 {
		return C.CString("running")
	}
	return C.CString("stopped")
}

//export GetVersion
func GetVersion() *C.char {
	return C.CString("eycorsican/go-tun2socks-lwip")
}

//export InputTunPacket
func InputTunPacket(data *C.char, length C.int) C.int {
	if data == nil || length <= 0 {
		return -1
	}
	if atomic.LoadInt32(&started) == 0 {
		return -2
	}
	buf := C.GoBytes(unsafe.Pointer(data), length)
	if n, err := coreInput(buf); err != nil || n <= 0 {
		return -3
	}
	return 0
}

// coreInput wraps core.input (unexported) for feeding packets.
func coreInput(b []byte) (int, error) { // same package main; calls into core via exported cgo
	return coreInputImpl(b)
}

//go:linkname coreInputImpl github.com/eycorsican/go-tun2socks/core.input
func coreInputImpl(b []byte) (int, error)

func main() {}
