#!/bin/sh
# Install goodverify CLI on macOS/Linux.
set -e

VERSION="${GOODVERIFY_VERSION:-latest}"
INSTALL_DIR="${GOODVERIFY_INSTALL_DIR:-/usr/local/bin}"
BASE_URL="${GOODVERIFY_BASE_URL:-https://github.com/goodwaygroup/goodverify/releases/download}"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64|amd64)  ARCH="amd64" ;;
    aarch64|arm64)  ARCH="arm64" ;;
    *)  echo "Error: unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

case "$OS" in
    darwin|linux) ;;
    msys*|mingw*|cygwin*)
        echo "Error: use install.ps1 for native Windows installs" >&2
        exit 1
        ;;
    *)  echo "Error: unsupported OS: $OS" >&2; exit 1 ;;
esac

BINARY="goodverify-${OS}-${ARCH}"

if [ "$VERSION" = "latest" ]; then
    URL="${BASE_URL}/latest/download/${BINARY}"
else
    URL="${BASE_URL}/v${VERSION}/${BINARY}"
fi

echo "Downloading goodverify for ${OS}/${ARCH}..."

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "${TMPDIR}/goodverify" "$URL"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "${TMPDIR}/goodverify" "$URL"
else
    echo "Error: curl or wget is required" >&2; exit 1
fi

chmod +x "${TMPDIR}/goodverify"

if [ -w "$INSTALL_DIR" ]; then
    mv "${TMPDIR}/goodverify" "${INSTALL_DIR}/goodverify"
else
    echo "Installing to ${INSTALL_DIR} (requires sudo)..."
    sudo mv "${TMPDIR}/goodverify" "${INSTALL_DIR}/goodverify"
fi

echo "goodverify installed to ${INSTALL_DIR}/goodverify"
goodverify --version
