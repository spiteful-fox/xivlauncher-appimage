podman := require("podman")
git := require("git")
build_image := "xivlauncher-appimage-builder"

@default:
    just --list

# Build an AppImage based on a given config (currently, either 'xivlauncher' or 'xivlauncher-rb')
[group('build')]
build config-name="xivlauncher" rebuild="false": (build-image rebuild)
    mkdir -p output
    "{{ podman }}" run --rm \
        -v $(pwd)/output:/src/appimage-build/output \
        xivlauncher-appimage-builder create-appimage {{ config-name }}

# Build or rebuild the container image used for building the AppImage.
[group('build')]
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

# Remove the container image as well as built AppImages.
[group('build')]
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Removing Docker image {{ build_image }}..."
    "{{ podman }}" rmi {{ build_image }} 2>/dev/null || echo "Image not found, skipping..."
    echo "Removing output folder..."
    rm -rf output


# Creates a git tag according to the current date, or a given tag.
[group('git')]
tag-commit tag="":
    #!/usr/bin/env ruby
    tags = `"{{ git }}" tag`.split.map(&:strip)
    new_tag = "{{ tag }}".empty? ? Time.now.strftime("%Y-%m-%d") : "{{ tag }}"
    tags.reject!{|i| /^#{new_tag}(\.(\d+))*$/.match(i).nil?}
    new_tag += ".#{tags.length}" if tags.length > 0
    `"{{ git }}" tag #{new_tag}`
    puts new_tag
