set shell := ["bash", "-c"]

wget := shell("which wget")
tool_dir := absolute_path("tools")
appimagetool := tool_dir + "/appimagetool"
aria2c := tool_dir + "/aria2c"
busybox := tool_dir + "/busybox"
config_file := absolute_path("config.json")
cache_dir := absolute_path(".cache")

create-appimage dir-name: get-aria2c get-appimagetool get-busybox (download dir-name)
    #!/usr/bin/env ruby
    require "fileutils"; include FileUtils
    require "pathname"

    class String
      def relative(resolve)
        Pathname.new(self).relative_path_from(resolve).to_s
      end
    end

    XIVLAUNCHER_EXEC_NAME = `just get-config-value {{ dir-name }} executable`.strip
    XIVLAUNCHER_VERSION = `just get-config-value {{ dir-name }} version`.strip
    XIVLAUNCHER_SOURCE = `just get-config-value {{ dir-name }} src`.strip
    XIVLAUNCHER_NAME = `just get-config-value {{ dir-name }} name`.strip
    XIVLAUNCHER_DESC = `just get-config-value {{ dir-name }} description`.strip
    XIVLAUNCHER_UPDATE_URL = `just get-config-value {{ dir-name }} update_url`.strip

    APPDIR = File.join(Dir.pwd, "appdir", XIVLAUNCHER_EXEC_NAME)
    INSTALL_PATH = File.join(APPDIR, "opt", XIVLAUNCHER_EXEC_NAME)
    DESKTOP_FILE_PATH = File.join(APPDIR, "usr", "share", "applications", "#{XIVLAUNCHER_EXEC_NAME}.desktop")
    ICON_PATH = File.join(APPDIR, "usr", "share", "icons", "#{XIVLAUNCHER_EXEC_NAME}.png")

    BINDIR = File.join(APPDIR, "usr", "bin")
    EXECUTABLE_INSTALL_PATH = File.join(BINDIR, XIVLAUNCHER_EXEC_NAME)
    BUSYBOX_INSTALL_PATH = File.join(BINDIR, "busybox")

    UPDATE_DATA = "gh-releases-zsync|spiteful-fox|xivlauncher-appimage|latest|#{XIVLAUNCHER_NAME}-x86_64.AppImage.zsync"

    mkdir_p File.join(Dir.pwd, "appdir")
    cp_r "AppDir.template", APPDIR
    cp_r File.join(Dir.pwd, "src", "{{ dir-name }}"), INSTALL_PATH
    cp File.join("resources", "xivlauncher.png"), ICON_PATH
    cp "{{ aria2c }}", BINDIR

    cp "{{ busybox }}", BUSYBOX_INSTALL_PATH
    `"#{BUSYBOX_INSTALL_PATH}" --list`.split("\n").each{|e| ln_sf BUSYBOX_INSTALL_PATH.relative(BINDIR), File.join(BINDIR, e.strip)}


    desktop_file = File.read(File.join("resources", "xivlauncher.desktop")) % {
      name: XIVLAUNCHER_NAME,
      description: XIVLAUNCHER_DESC,
      executable: XIVLAUNCHER_EXEC_NAME
    }
    File.write(DESKTOP_FILE_PATH, desktop_file)

    executable = File.read(File.join("resources", "xivlauncher.sh")) % {executable: XIVLAUNCHER_EXEC_NAME}
    File.write(EXECUTABLE_INSTALL_PATH, executable)
    chmod "+x", EXECUTABLE_INSTALL_PATH

    [File.join(INSTALL_PATH, "XIVLauncher.Core"), Dir["#{INSTALL_PATH}/**/*.so"]].flatten.each do |obj|
      `just copy-dependencies "#{obj}" #{XIVLAUNCHER_EXEC_NAME}`
      chmod_R "+x", File.join(APPDIR, "usr", "lib")
    end

    ["libjxr0", "libsdl2-2.0-0", "libsecret-1-0", "libicu-dev"].each{|l| `just copy-package-libraries #{l} #{XIVLAUNCHER_EXEC_NAME}`}


    ln_sf Pathname.new(EXECUTABLE_INSTALL_PATH).relative_path_from(APPDIR), File.join(APPDIR, "AppRun")
    ln_sf Pathname.new(DESKTOP_FILE_PATH).relative_path_from(APPDIR), File.join(APPDIR, "#{XIVLAUNCHER_EXEC_NAME}.desktop")
    ln_sf Pathname.new(ICON_PATH).relative_path_from(APPDIR), File.join(APPDIR, "#{XIVLAUNCHER_EXEC_NAME}.png")

    `"{{ appimagetool }}" -u "#{UPDATE_DATA}" "#{APPDIR}"`

copy-dependencies source-object dir-name:
    #!/usr/bin/env ruby
    require "fileutils"; include FileUtils

    LIBDIR = File.join(Dir.pwd, "appdir", "{{ dir-name }}", "usr", "lib")
    mkdir_p LIBDIR
    SEARCHED_FILES = []
    EXCLUDED_LIBRARIES = [
      ["c", "stdc++", "dl", "rt", "pthread", "m"],
      ["wayland-client", "wayland-cursor", "wayland-egl", "wayland-server"],
      ["xcb", "xkbcommon", "X11", "X11-xcb", "Xau", "Xcursor", "Xdmcp", "Xext", "Xfixes", "Xi", "Xrandr", "Xrender", "Xss"]
    ].flatten.map{|i|"lib"+i}

    def get_deps(src)
      objects = []
      return objects if SEARCHED_FILES.include?(src)
      results = `ldd "#{src}"`.split("\n").map{|s|s.strip}
      results.each do |r|
        matchdata = /^(.+) => (.+) \(0x[{{ HEXLOWER }}]+\)$/.match(r)
        if matchdata
          lib = matchdata.captures[1]
          objects << lib
        end
      end
      SEARCHED_FILES << src
      objects.each do |obj|
        objects |= get_deps(obj)
      end
      objects
    end

    get_deps("{{ source-object }}").each do |lib|
      destination = File.join(LIBDIR, File.basename(lib))
      exc = !EXCLUDED_LIBRARIES.select{|i| File.basename(lib).split(".")[0] == i}.empty?
      unless File.exist?(destination) || exc
        cp lib, destination
      end
    end

copy-package-libraries package-name dir-name:
    #!/usr/bin/env ruby
    require "fileutils"; include FileUtils

    LIBDIR = File.join(Dir.pwd, "appdir", "{{ dir-name }}", "usr", "lib")

    objects = []
    `dpkg-query -L {{ package-name }}`.each_line do |line|
      matchdata = /^(.+\.so(\.\d)*)$/.match(line.strip)
      if matchdata
        objects << matchdata.captures[0]
      end
    end
    objects.each do |obj|
      cp "#{obj}", LIBDIR
      `just copy-dependencies "#{obj}" {{ dir-name }}`
    end

download config-name:
    #!/usr/bin/env ruby
    require 'fileutils'; include FileUtils

    mkdir_p "{{ cache_dir }}"
    mkdir_p "{{ absolute_path('src') }}"
    bin_extract_dir = File.join("src", `just get-config-value {{ config-name }} executable`.strip)
    mkdir_p bin_extract_dir
    src = `just get-config-value {{ config-name }} src`.strip % {version: `just get-config-value {{ config-name }} version`.strip}
    archive_name = File.basename(src)
    dest = File.join("{{ cache_dir }}", `just get-config-value {{ config-name }} executable`.strip + ".tar.gz")
    dest_dir = dest.sub(".tar.gz", "")
    if !File.exist?(dest)
      `"{{ wget }}" -O #{dest} #{src}`
    end
    if !File.exist?(File.join(bin_extract_dir, "XIVLauncher.Core"))
      `tar -xzf "#{dest}" -C "#{bin_extract_dir}"`
    end

get-appimagetool:
    #!/usr/bin/env bash
    mkdir -p tools

    if [ ! -f "{{ appimagetool }}" ]; then
        "{{ wget }}" "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-{{ arch() }}.AppImage" -O "{{ absolute_path("tools") }}/appimagetool"
        chmod +x "{{ absolute_path("tools") }}/appimagetool"
    fi

get-aria2c:
    #!/usr/bin/env bash
    mkdir -p tools

    if [ ! -f "{{ aria2c }}" ]; then
        "{{ wget }}" -qO- "https://github.com/abcfy2/aria2-static-build/releases/download/continuous/aria2-x86_64-linux-musl_static.zip" | zcat > "{{ aria2c }}"
        chmod +x "{{ aria2c }}"
    fi

get-busybox:
    #!/usr/bin/env bash
    mkdir -p tools

    if [ ! -f "{{ busybox }}" ]; then
        "{{ wget }}" https://github.com/ruanformigoni/busybox-static-musl/releases/download/7e2c5b6/busybox-x86_64 -O "{{ busybox }}"
        chmod +x "{{ busybox }}"
    fi

get-config-value name key:
    #!/usr/bin/env ruby
    require 'json'
    puts JSON.parse(File.read("{{ config_file }}"))["{{ name }}"]["{{ key }}"].to_s

clean:
    rm -rf *.AppImage *.zsync tools appdir src .cache
