#!/bin/sh
set -e

REPO="tassiovirginio/dnose"
BIN_NAME="dnose"
ASSET_NAME="dnose_linux_amd64"

# ANSI colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"

echo "${BLUE}==> Fetching latest release of $BIN_NAME...${RESET}"

# Require curl or wget
if command -v curl >/dev/null 2>&1; then
    FETCH_CMD="curl -sSL"
elif command -v wget >/dev/null 2>&1; then
    FETCH_CMD="wget -qO-"
else
    echo "${RED}Error: curl or wget is required to install $BIN_NAME.${RESET}"
    exit 1
fi

# Fetch latest release tag
LATEST_RELEASE=$($FETCH_CMD "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
    echo "${RED}Error: Could not retrieve latest release from GitHub.${RESET}"
    exit 1
fi

echo "${BLUE}==> Latest release is $LATEST_RELEASE${RESET}"

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/$ASSET_NAME"

# Determine installation directory based on user privileges
INSTALL_DIR="$HOME/.local/bin"
if [ "$(id -u)" = "0" ]; then
    INSTALL_DIR="/usr/local/bin"
fi

# Ensure the installation directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo "${BLUE}==> Creating directory $INSTALL_DIR...${RESET}"
    mkdir -p "$INSTALL_DIR"
fi

echo "${BLUE}==> Downloading $BIN_NAME to $INSTALL_DIR...${RESET}"
if command -v curl >/dev/null 2>&1; then
    curl -sSL "$DOWNLOAD_URL" -o "$INSTALL_DIR/$BIN_NAME"
else
    wget -q "$DOWNLOAD_URL" -O "$INSTALL_DIR/$BIN_NAME"
fi
chmod +x "$INSTALL_DIR/$BIN_NAME"

echo "${GREEN}==> $BIN_NAME installed successfully in $INSTALL_DIR!${RESET}"

# Check if INSTALL_DIR is in PATH
if echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "${GREEN}==> You can now run '$BIN_NAME' from anywhere.${RESET}"
else
    echo "${RED}==> Warning: $INSTALL_DIR is not in your PATH.${RESET}"
    echo "    Please add the following line to your ~/.bashrc, ~/.zshrc, or equivalent profile file:"
    echo ""
    echo "    export PATH=\"\$PATH:$INSTALL_DIR\""
    echo ""
    echo "    After adding it, restart your terminal or run: source ~/.bashrc"
fi
