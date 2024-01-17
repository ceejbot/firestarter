set windows-shell := ["pwsh.exe", "-Command"]
set shell := ["bash", "-uc"]

# The target you want to build for.
preset := "vs2022-windows"

# The location of a target development mod.
TESTMOD := "/mnt/g/MO2Skyrim/firestarter-dev"
DLL_BASENAME := "firestarter"
PLUGIN_FILE := "firestarter.esp"
SPRIGGIT := "~/bin/spriggit"

# List recipes
_help:
	@just -l

# Build everything from a clean repo. One-stop shop.
full-build: submodules tools cmake build

# Wrangle git submodules
@submodules:
	git submodule update --init --recursive

# Install all tools for unix-likes.
[unix]
tools:
	#!/bin/bash
	if [[ -z $(which rustup) ]]; then
		echo "Rustup not found. Please install rust for your platform: https://rustup.rs/"
		exit 1
	fi
	if [[ -z $(which brew) ]]; then
		echo "Homebrew not found. Please install it: https://brew.sh"
		echo "Alternatively, install cmake and ninja through other means."
		exit 1
	fi
	set -e
	rustup install nightly
	cargo install cargo-nextest

# Install tools for windows. You are expected to have cmake and ninja already.
[windows]
tools:
	rustup install nightly
	cargo install cargo-nextest

# Run cmake to generate build files.
cmake:
	cmake --preset {{preset}}

# Do a debug build.
debug:
	cargo build
	cmake --build --preset {{preset}} --config Debug

# Run cmake to build for release.
build:
	cargo build --release
	cmake --build --preset {{preset}} --config Release

# Format both C++ and Rust source.
format:
	cargo +nightly fmt
	find src -iname '*.h' -o -iname '*.cpp' | xargs clang-format -i

# Lint.
lint:
	cargo clippy --all-targets --no-deps

# Run tests with nextest.
test:
	cargo nextest run

# check that all $ strings in config have matching translation strings
[unix]
check-translations:
	mcm-meta-helper --moddir installer/core check all

# Use spriggit to dump the plugin to text.
plugin-ser:
    {{SPRIGGIT}} serialize --InputPath ./installer/core/{{PLUGIN_FILE}} --OutputPath ./plugin/ --GameRelease SkyrimSE --PackageName Spriggit.Json

# Use spriggit to rehydrate the plugin.
@plugin-de:
    {{SPRIGGIT}} deserialize --InputPath ./plugin --OutputPath ./test_{{PLUGIN_FILE}}

# Generate source files list for CMake. Requires bash.
[unix]
sources:
    #!/bin/bash
    set -e
    echo "set(headers \${headers}" > test.txt
    headers=$(find ./src -name \*\.h | sort)
    echo "${headers}" >> test.txt
    echo ")" >> test.txt
    echo "set(sources \${sources}" >> test.txt
    echo "    \${headers}" >> test.txt
    cpps=$(find ./src -name \*\.cpp | sort)
    echo "${cpps}" >> test.txt
    echo ")" >> test.txt
    sed -e 's/^\.\//    /' test.txt > cmake/sourcelist.cmake
    rm test.txt

# Copy the built mod files to the test mod. Can use rsync to copy many files.
[unix]
install:
	#!/usr/bin/env bash
	echo "copying to live mod for testing..."
	mkdir -p "{{TESTMOD}}"/SKSE/plugins
	echo "{{TESTMOD}}"
	cp -p build/Release/"{{DLL_BASENAME}}".{dll,pdb} "{{TESTMOD}}"/SKSE/plugins/

[windows]
@sources:
	echo "Run this where you have bash."

[windows]
@install:
	echo "Run this where you have bash."
