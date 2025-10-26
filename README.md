# XIVLauncher AppImages

Unofficial AppImage builds of [XIVLauncher](https://github.com/goatcorp/XIVLauncher.Core) and [XIVLauncher-RB](https://github.com/rankynbass/XIVLauncher.Core). They should work on all of the popular distributions and things based on them (Debian/Ubuntu, Fedora, Arch, etc...). They were especially made for Bazzite, to make it easier to install the native versions of XIVLauncher(-RB) without teaching Distrobox or needing to use layering.

#### Installing

They're just AppImages, so you could simply head to the [releases page](https://github.com/spiteful-fox/xivlauncher-appimage/releases), download them, and run them directly. You could also use something like [Gear Lever](https://flathub.org/en/apps/it.mijorus.gearlever) to install them (which I recommend doing).

From a terminal, assuming [Flatpak is already installed](https://flatpak.org/setup/), you can install both Gear Lever and this AppImage with:

```sh
curl -s https://raw.githubusercontent.com/spiteful-fox/xivlauncher-appimage/refs/heads/main/install.sh | bash
```
or, for XIVLauncher-RB:
```sh
curl -s https://raw.githubusercontent.com/spiteful-fox/xivlauncher-appimage/refs/heads/main/install.sh | bash -s rb
```

First, a system-level installation of Gear Lever will be attempted. If that doesn't work (no sudo), it will be installed at the user level instead.

#### Building

##### Requirements:
- just
- podman

```sh
# For XIVLauncher
just build

# For XIVLauncher-RB
just build xivlauncher-rb

# clean the image build and cache
just clean
```
