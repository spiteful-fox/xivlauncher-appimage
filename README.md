# XIVLauncher AppImages

Unofficial AppImage builds of [XIVLauncher](https://github.com/goatcorp/XIVLauncher.Core) and [XIVLauncher-RB](https://github.com/rankynbass/XIVLauncher.Core). They should work on all of the popular distributions and things based on them (Debian/Ubuntu, Fedora, Arch, etc...). They were especially made for Bazzite, to make it easier to install the native versions of XIVLauncher(-RB) without teaching Distrobox or needing to use layering.

#### Installing

They're just AppImages, so you could simply head to the releases page, download them, and run them directly. You could also use something like [Gear Lever](https://flathub.org/en/apps/it.mijorus.gearlever) to install them (which I recommend doing).

From a terminal, you could install it automatically with:

```sh
curl -s https://raw.githubusercontent.com/spiteful-fox/xivlauncher-appimage/refs/heads/main/install.sh | bash
```
or, for XIVLauncher-RB:
```sh
curl -s https://raw.githubusercontent.com/spiteful-fox/xivlauncher-appimage/refs/heads/main/install-rb.sh | bash -s --rb
```

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
