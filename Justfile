podman := require("podman")
build_image := "xivlauncher-appimage-builder"

default:
    just --list

build config-name="xivlauncher" rebuild="false": (build-image rebuild)
    mkdir -p output
    "{{ podman }}" run --rm \
        -v $(pwd)/output:/src/appimage-build/output \
        xivlauncher-appimage-builder create-appimage {{ config-name }}

build-image rebuild="false":
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{ rebuild }}" == "true" ]]; then
        echo "Rebuilding image..."
        "{{ podman }}" build \
        --no-cache -t {{ build_image }} .
    else
        if ! "{{ podman }}" image inspect {{ build_image }} >/dev/null 2>&1; then
            echo "Image not found, building..."
            "{{ podman }}" build -t {{ build_image }} .
        else
            echo "Image already exists, skipping build"
        fi
    fi

clean:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Removing Docker image {{ build_image }}..."
    "{{ podman }}" rmi {{ build_image }} 2>/dev/null || echo "Image not found, skipping..."
    echo "Removing output folder..."
    rm -rf output
