# goodverify build recipes

version := `grep '\.version' build.zig.zon | head -1 | sed 's/.*"\(.*\)".*/\1/'`
dist := "dist"

# Build debug binary
build:
    zig build

# Build release binary (native platform)
release:
    zig build -Doptimize=ReleaseSafe

# Bump version in build.zig.zon (major, minor, or patch)
bump part="patch":
    #!/usr/bin/env sh
    IFS='.' read -r major minor patch <<< "{{version}}"
    case "{{part}}" in
        major) major=$((major + 1)); minor=0; patch=0 ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        patch) patch=$((patch + 1)) ;;
        *) echo "Error: use 'major', 'minor', or 'patch'" >&2; exit 1 ;;
    esac
    new="${major}.${minor}.${patch}"
    sed -i '' "s/\.version = \"{{version}}\"/\.version = \"${new}\"/" build.zig.zon
    echo "{{version}} → ${new}"

repo := "agoodway/goodverify_cli"

# Push subtree to remote, tag, and publish a GitHub release
publish: test dist checksums
    cd .. && git subtree push --prefix=cli-zig git@github.com:{{repo}}.git main
    gh api repos/{{repo}}/git/refs -f ref="refs/tags/v{{version}}" -f sha="$(gh api repos/{{repo}}/commits/main --jq '.sha')"
    gh release create "v{{version}}" {{dist}}/* --repo {{repo}} --title "v{{version}}" --generate-notes

# Run with arguments
run *ARGS:
    zig build run -- {{ARGS}}

# Run tests
test:
    zig build test

# Build release binaries for all supported platforms into dist/
dist: clean-dist
    mkdir -p {{dist}}
    @echo "Building darwin-arm64..."
    zig build -Dtarget=aarch64-macos -Doptimize=ReleaseSafe
    cp zig-out/bin/goodverify {{dist}}/goodverify-darwin-arm64
    @echo "Building darwin-amd64..."
    zig build -Dtarget=x86_64-macos -Doptimize=ReleaseSafe
    cp zig-out/bin/goodverify {{dist}}/goodverify-darwin-amd64
    @echo "Building linux-amd64..."
    zig build -Dtarget=x86_64-linux -Doptimize=ReleaseSafe
    cp zig-out/bin/goodverify {{dist}}/goodverify-linux-amd64
    @echo "Building linux-arm64..."
    zig build -Dtarget=aarch64-linux -Doptimize=ReleaseSafe
    cp zig-out/bin/goodverify {{dist}}/goodverify-linux-arm64
    @echo "Building windows-amd64..."
    zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSafe
    cp zig-out/bin/goodverify.exe {{dist}}/goodverify-windows-amd64.exe
    @echo "Building windows-arm64..."
    zig build -Dtarget=aarch64-windows -Doptimize=ReleaseSafe
    cp zig-out/bin/goodverify.exe {{dist}}/goodverify-windows-arm64.exe
    @echo "Done. Binaries in {{dist}}/"
    ls -lh {{dist}}/

# Generate checksums for dist binaries
checksums:
    cd {{dist}} && shasum -a 256 goodverify-* > checksums.txt
    cat {{dist}}/checksums.txt

# Regenerate API client from OpenAPI spec (requires manual fixes after)
generate:
    ~/.local/bin/openapi2zig generate -i ../app/openapi.json -o src/generated.zig
    @echo "IMPORTANT: Generated code needs manual fixes for Zig 0.15.2 — see CLAUDE.md"

# Clean build artifacts
clean:
    rm -rf zig-out .zig-cache

# Clean dist directory
clean-dist:
    rm -rf {{dist}}

# Clean everything
clean-all: clean clean-dist
