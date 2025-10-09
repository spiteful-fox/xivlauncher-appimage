# XIVLauncher AppImages

Unofficial AppImage builds of [XIVLauncher](https://github.com/goatcorp/XIVLauncher.Core) and [XIVLauncher-RB](https://github.com/rankynbass/XIVLauncher.Core). I've tested it on live images of Fedora/Ultramarine, Nobara, CachyOS, PikaOS, and Ubuntu. It launches, patches, and runs the game on all of them, so I'm hoping that means it's good enough to give it a pass, compatibility-wise, so give it a shot and it *should* work... probably.

The build script is a bit of a mess, but I will work on it more when I have time. Right now, you need Debian 12 to build this (and I won't get around to making a Dockerfile to make that a bit easier until later), so I'd probably recommend just using distrobox.

Requirements:
- Debian 12
- [Just](https://github.com/casey/just)
- Ruby
- SDL2
- libjxr
- libsecret
- libicu
- fuse3

#### Building with distrobox

```sh
yes | distrobox create -n build-xivlauncher-appimage -i debian:12
distrobox enter build-xivlauncher-appimage
sudo apt install -y ruby lsb-release libjxr0 libsdl2-2.0-0 libsecret-1-0 libicu-dev fuse3

wget -qO - 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
echo "deb [arch=all,$(dpkg --print-architecture) signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list
sudo apt update

sudo apt install -y just

# and, from then on
distrobox enter build-xivlauncher-appimage -- just create-appimage xivlauncher # or xivlauncher-rb
```
