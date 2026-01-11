#!/bin/bash

# ══════════════════════════════════════════════════════════════════════════════
# hl-pnl Installer
# Hyperliquid Position PnL CLI Tool
# ══════════════════════════════════════════════════════════════════════════════

set -e

REPO="born1337/hyperliquid-pnl-cli"
BINARY_NAME="hl-pnl"

# Colors
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
WHITE='\033[1;97m'
DIM='\033[0;90m'
NC='\033[0m'

# Default install directory
INSTALL_DIR="/usr/local/bin"
USER_INSTALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user|-u)
            USER_INSTALL=true
            INSTALL_DIR="$HOME/.local/bin"
            shift
            ;;
        --help|-h)
            echo "Usage: install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --user, -u    Install to ~/.local/bin (no sudo required)"
            echo "  --help, -h    Show this help message"
            echo ""
            echo "Default: Install to /usr/local/bin (requires sudo)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}hl-pnl Installer${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check for required dependencies
echo -e "${WHITE}Checking dependencies...${NC}"

missing_deps=()

if ! command -v curl &>/dev/null; then
    missing_deps+=("curl")
fi

if ! command -v jq &>/dev/null; then
    missing_deps+=("jq")
fi

if ! command -v awk &>/dev/null; then
    missing_deps+=("awk")
fi

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${YELLOW}Missing dependencies: ${missing_deps[*]}${NC}"
    echo ""

    # Detect OS and suggest install command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "Install with: ${GREEN}brew install ${missing_deps[*]}${NC}"
    elif command -v apt-get &>/dev/null; then
        echo -e "Install with: ${GREEN}sudo apt-get install ${missing_deps[*]}${NC}"
    elif command -v yum &>/dev/null; then
        echo -e "Install with: ${GREEN}sudo yum install ${missing_deps[*]}${NC}"
    elif command -v pacman &>/dev/null; then
        echo -e "Install with: ${GREEN}sudo pacman -S ${missing_deps[*]}${NC}"
    fi

    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Installation cancelled.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}All dependencies found!${NC}"
fi

echo ""

# Create install directory if needed (for user install)
if [[ "$USER_INSTALL" == true ]] && [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "${WHITE}Creating ${INSTALL_DIR}...${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Download the script
echo -e "${WHITE}Downloading hl-pnl...${NC}"

DOWNLOAD_URL="https://raw.githubusercontent.com/${REPO}/main/hl-pnl"
TMP_FILE=$(mktemp)

if curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
    echo -e "${GREEN}Download successful!${NC}"
else
    echo -e "${RED}Error: Failed to download hl-pnl${NC}"
    echo "URL: $DOWNLOAD_URL"
    rm -f "$TMP_FILE"
    exit 1
fi

echo ""

# Install the script
echo -e "${WHITE}Installing to ${INSTALL_DIR}...${NC}"

# Check if we need sudo
if [ -w "$INSTALL_DIR" ] || [[ "$USER_INSTALL" == true ]]; then
    mv "$TMP_FILE" "${INSTALL_DIR}/${BINARY_NAME}"
    chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
else
    echo -e "${YELLOW}Requires sudo to install to ${INSTALL_DIR}${NC}"
    echo -e "${DIM}Tip: Use --user flag to install without sudo${NC}"
    sudo mv "$TMP_FILE" "${INSTALL_DIR}/${BINARY_NAME}"
    sudo chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
fi

echo -e "${GREEN}Installation successful!${NC}"
echo ""

# Check if install dir is in PATH
IN_PATH=false
if echo "$PATH" | grep -q "$INSTALL_DIR"; then
    IN_PATH=true
fi

# Verify installation
if [[ "$IN_PATH" == true ]] && command -v "$BINARY_NAME" &>/dev/null; then
    VERSION=$("$BINARY_NAME" --version 2>/dev/null || echo "unknown")
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ hl-pnl installed successfully!${NC}"
    echo -e "  Version: ${WHITE}${VERSION}${NC}"
    echo -e "  Location: ${WHITE}${INSTALL_DIR}/${BINARY_NAME}${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}Usage:${NC}"
    echo -e "  ${GREEN}hl-pnl <address>${NC}              Check positions"
    echo -e "  ${GREEN}hl-pnl <address> --watch 30${NC}   Watch mode (refresh every 30s)"
    echo -e "  ${GREEN}hl-pnl <address> --vaults${NC}     Show vault investments"
    echo -e "  ${GREEN}hl-pnl --help${NC}                 Show all options"
    echo ""
else
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ hl-pnl installed to ${INSTALL_DIR}/${BINARY_NAME}${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    if [[ "$IN_PATH" == false ]]; then
        echo -e "${YELLOW}Note: ${INSTALL_DIR} is not in your PATH${NC}"
        echo ""
        echo -e "${WHITE}Add to PATH by running:${NC}"

        # Detect shell
        SHELL_NAME=$(basename "$SHELL")
        case "$SHELL_NAME" in
            zsh)
                echo -e "  ${GREEN}echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.zshrc${NC}"
                echo -e "  ${GREEN}source ~/.zshrc${NC}"
                ;;
            bash)
                echo -e "  ${GREEN}echo 'export PATH=\"${INSTALL_DIR}:\$PATH\"' >> ~/.bashrc${NC}"
                echo -e "  ${GREEN}source ~/.bashrc${NC}"
                ;;
            *)
                echo -e "  ${GREEN}export PATH=\"${INSTALL_DIR}:\$PATH\"${NC}"
                ;;
        esac
        echo ""
    fi

    echo -e "${WHITE}Or run directly:${NC}"
    echo -e "  ${GREEN}${INSTALL_DIR}/${BINARY_NAME} --help${NC}"
    echo ""
fi
