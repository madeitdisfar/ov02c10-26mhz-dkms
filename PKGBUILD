# Maintainer: Minjun Kim <mjkim5216@gmail.com>

# The kernel's ov02c10 camera sensor driver with support for a 26 MHz
# external clock, as DKMS module, plus the libcamera tuning file and
# WirePlumber rule for the Samsung Galaxy Book4 Pro (940XGK) camera.
# See README.md. Remove the package to go back to the stock driver.

pkgname=ov02c10-26mhz-dkms
_kver=7.2.11
pkgver=$_kver
pkgrel=4
pkgdesc="OmniVision OV02C10 sensor driver with 26 MHz clock support (DKMS), for the Galaxy Book4 Pro camera"
arch=(any)
url="https://www.kernel.org/"
license=(GPL-2.0-only MIT CC0-1.0)
depends=(dkms)
optdepends=(
  'libcamera: camera stack the sensor is used through'
  'pipewire-libcamera: PipeWire camera support'
)
source=(
  "ov02c10.c::https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/media/i2c/ov02c10.c?h=v$_kver"
  ov02c10-26mhz.patch
  Kbuild
  Makefile
  dkms.conf
  ov02c10.yaml
  51-ipu6-camera.conf
  LICENSE
)
b2sums=('655f5a7e24075f4bc25c53740be6e81d8d8ae01cf48814c7b964847fc07b7c150fbaf1ffbc65ead79fc2c53267aaa2fea18aa43cd128509627a1652a78e8684a'
        '3f1abad78c8b96dd0f1713eeaa22c6628a267b8c15276fc953be216e3cf1d4f3d7c611cba4a207c3af8b9a30a77786b0c17fe95f36a776c314620248f0a57f6a'
        '8d433a015e9c7a83bb9d2338cbb496b16e14377004e17c5175608abbba127d7efd9792a76dd810ceaeaa156cf377cc42c281a4bc97761b5e78dae7535d877518'
        'ceb6a32db6cca8cd7a46c6ca943cc7c6490a114de12d4f79173ea5f01a4b4e0a147a63ebc09d3447a95984d5aebb3e045ee7c38d255740ab7c49ce0087ad38df'
        'd636e213ca44397f0decc18a57c5e74af19686cbe15fa6e6e7cc446187ece1d4473d978bc058aa5cf72783a8bc93b288c0f038e226871d2b548430ae382a5171'
        '4484ba29876cb5ed911c990d9d6b7bf0bb6a44687d0dee7b5223a1102f7bcd32bfaa4c0402f5c44423dfb7d5ae38ff2819cacf8a5f41789305f9cd0a1d0536d6'
        '90a322d20776db4939d1b9fce0cd1a182247416a838adbfbe3c2bb358dcc80f222f771063165054bd05b8da43e7b3656aecb1dd5e22825be6c6c5915c1b1e9c2'
        '9b7d79f59e653ba1537fccc2b1dad05e45c32511ad9937c2dba04ec392974ad46300aa0bc428b58e60ef312965d6788802089b28f21de6bef4300c80e560eee4')

prepare() {
  # The download is a symlink; write the patched driver to its own file
  cp -fL ov02c10.c ov02c10-patched.c
  patch -Np4 -i ov02c10-26mhz.patch ov02c10-patched.c
}

package() {
  local _dst="$pkgdir/usr/src/ov02c10-26mhz-$pkgver"
  install -Dm644 ov02c10-patched.c "$_dst/ov02c10.c"
  install -Dm644 Kbuild Makefile -t "$_dst"
  sed "s/@PKGVER@/$pkgver/" dkms.conf > dkms.conf.out
  install -Dm644 dkms.conf.out "$_dst/dkms.conf"

  install -Dm644 ov02c10.yaml -t "$pkgdir/usr/share/libcamera/ipa/simple"
  install -Dm644 51-ipu6-camera.conf -t "$pkgdir/usr/share/wireplumber/wireplumber.conf.d"
  install -Dm644 LICENSE -t "$pkgdir/usr/share/licenses/$pkgname"
}
