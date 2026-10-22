# ov02c10-26mhz-dkms

An Arch package that makes the built-in camera of the Samsung Galaxy Book4 Pro 14" (940XGK) work on Linux: the kernel's OmniVision OV02C10 sensor driver with support for a 26 MHz clock, built with DKMS, plus the libcamera tuning file and WirePlumber rule the camera needs.

## The problem

The camera is an OV02C10 sensor on the Intel IPU6. On this laptop the sensor gets a fixed 26 MHz clock (from an INT3472 discrete device, which can't be reprogrammed), but the kernel driver only accepts 19.2 MHz:

```
ov02c10 i2c-OVTI02C1:00: error -EINVAL: external clock 26000000 is not supported
```

So there is no camera at all.

## The fix

`ov02c10-26mhz.patch` (against the driver in kernel 7.2.11):

- **26 MHz clock.** On top of the 19.2 MHz register tables, it applies the overrides from the vendor's Windows driver (`OV02C10.sys`) for the same mode: PLL1 for a 333.125 MHz MIPI link with matching MIPI timing, and the system PLL (`0x0315`/`0x0316`, 400 -> 295) scaled so the pixel timing stays the same. The mode still runs at 30 fps with the same pixel rate. The Windows table only covers 2 lanes, so 26 MHz is refused with 1 lane.
- **Rotation.** The sensor is mounted upside down but the firmware reports 0 degrees; on this model the driver reports 180, and libcamera corrects it with the sensor's flips.
- **Selection.** `get_selection` reports the 1928x1092 pixel array, so libcamera doesn't have to guess it.

The package also installs:

- `/usr/share/libcamera/ipa/simple/ov02c10.yaml`: a colour correction matrix for libcamera's software ISP, fitted to a Windows photo of the same scene (without it, colours are washed out).
- `/usr/share/wireplumber/wireplumber.conf.d/51-ipu6-camera.conf`: hides the IPU6's 48 raw capture nodes from PipeWire, so apps only list the real camera ("Built-in Front Camera"). USB webcams are not affected. It also suspends the camera 0.2 s after it goes idle, without pausing it first: PipeWire's libcamera camera (1.6.9), reopened while paused (within the default 5 s), keeps sending only a few frames per second.

## How DKMS uses it

The package installs only source code, in `/usr/src/ov02c10-26mhz-7.2.11/`. DKMS builds it for each installed kernel and installs the module in `/usr/lib/modules/<kernel>/updates/dkms/`, which takes precedence over the kernel's own driver (that one isn't touched). When a kernel is updated, DKMS rebuilds the module automatically. The `Makefile` builds with Clang (`LLVM=1`) when the kernel was built with it, as CachyOS kernels are.

Only kernels 7.2 and newer are built for, since older kernels have a different sensor API. If a future kernel changes the driver's interfaces, the build fails during that kernel update, and the stock driver (no camera) is used until the patch is rebased.

## Build and install

```
sudo pacman -S --needed dkms
makepkg
sudo pacman -U ov02c10-26mhz-dkms-*.pkg.tar.zst
```

Then reboot, or reload the driver now (stop WirePlumber first; unbinding the sensor while it holds the camera can crash the kernel):

```
systemctl --user stop wireplumber
echo i2c-OVTI02C1:00 | sudo tee /sys/bus/i2c/drivers/ov02c10/unbind
sudo rmmod ov02c10
sudo modprobe ov02c10
systemctl --user start wireplumber
```

Images go through libcamera's software ISP, so `libcamera`, `libcamera-ipa` and `pipewire-libcamera` are needed. libcamera 0.7.2's GPU ISP draws magenta lines when the output is scaled; see [libcamera-softisp-fix](https://github.com/madeitdisfar/libcamera-softisp-fix) for a fix.

## Switching back

```
sudo pacman -R ov02c10-26mhz-dkms
```

DKMS removes the module from every kernel, and the stock driver is used from the next boot.

## Credits

- The [ov02c10 driver](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/media/i2c/ov02c10.c) by Hao Yao (Intel), Heimir Thor Sverrisson and Hans de Goede. The PKGBUILD downloads it from kernel.org at build time.
- The 26 MHz register values come from Intel's Windows driver for this laptop, read for interoperability. No Windows files are included.

## License

`ov02c10-26mhz.patch` modifies GPL-2.0 kernel code, so it's GPL-2.0-only (see `LICENSE.GPL-2.0`). `ov02c10.yaml` is CC0-1.0. Everything else is MIT (see `LICENSE`).
