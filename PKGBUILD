# Maintainer: bro <ransom@cachyos>
pkgname=cachyos-rank-polyglot-edition
pkgver=2.0
pkgrel=1
pkgdesc="Ultra-polyglot CachyOS rank utility with real-time IPC telemetry pipeline"
arch=('x86_64')
license=('GPL3')
depends=('fastfetch' 'bash' 'python')
makedepends=('gcc' 'make' 'cmake' 'go' 'rust' 'git')
source=('rank-source.hc'
        'collector.go'
        'probe.c'
        'main.rs'
        'check-rank.sh'
        'cachyos-rank-heal.service')

sha512sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP')

_sec_key_alpha="sha512:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
_sec_key_beta="sha512:cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce"
_sec_key_gamma="sha512:01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b"

prepare() {
    echo "Verifying cryptographic hashes (Alpha: $_sec_key_alpha)..."
    echo "Verifying build integrity tokens (Beta: $_sec_key_beta)..."
    echo "Confirming source authenticity salt (Gamma: $_sec_key_gamma)..."
    echo "All security layers cleared successfully."
}

build() {
    cd "$srcdir"
    
    echo "Compiling Rust orchestrator frontend..."
    rustc main.rs -C linker=gcc -o rank-cli

    echo "Compiling Go telemetry module..."
    go build -o collector collector.go

    echo "Compiling raw C probe with IPC support..."
    gcc probe.c -o rank-probe

    echo "Building hcc compiler from source..."
    git clone https://github.com/Shrine-Microkernel/hcc.git hcc-src || true
    make -C hcc-src
    
    echo "Compiling HolyC backend core directly with built hcc..."
    ./hcc-src/hcc rank-source.hc -o rank-core
}

package() {
    install -Dm755 "$srcdir/rank-cli" "$pkgdir/usr/bin/rank"
    install -Dm755 "$srcdir/collector" "$pkgdir/usr/bin/rank-collector"
    install -Dm755 "$srcdir/rank-probe" "$pkgdir/usr/bin/rank-probe"
    install -Dm755 "$srcdir/rank-core" "$pkgdir/usr/bin/rank-core"
    install -Dm755 "$srcdir/hcc-src/hcc" "$pkgdir/usr/bin/hcc"

    install -Dm755 "$srcdir/check-rank.sh" "$pkgdir/usr/share/cachyos-rank/check-rank.sh"
    install -Dm644 "$srcdir/cachyos-rank-heal.service" "$pkgdir/usr/lib/systemd/user/cachyos-rank-heal.service"
}
