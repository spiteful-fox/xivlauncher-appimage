FROM debian:12

RUN apt-get update && apt-get install -y \
    file \
    git \
    ruby \
    wget \
    curl \
    unzip \
    zsync \
    fuse3 \
    libjxr0 \
    libsdl2-2.0-0 \
    libsecret-1-0 \
    libicu-dev \
    dpkg-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

COPY . /src

WORKDIR /src/appimage-build

ENTRYPOINT ["just"]
CMD ["create-appimage", "xivlauncher"]
