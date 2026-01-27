FROM registry.gitlab.steamos.cloud/steamrt/sniper/sdk

RUN apt-get update && apt-get install -y \
    file \
    git \
    ruby \
    wget \
    curl \
    unzip \
    zsync \
    patchelf \
    fuse3 \
    luajit \
    libjxr-dev \
    libsdl2-dev \
    libsdl3-dev \
    libsdl3-image-dev \
    libsecret-1-dev \
    libicu-dev \
    dpkg-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

COPY . /src

WORKDIR /src/appimage-build

ENTRYPOINT ["/usr/local/bin/just"]
CMD ["create-appimage", "xivlauncher"]
