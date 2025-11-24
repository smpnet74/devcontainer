#!/bin/bash

# Pixi Environment Setup Script
# This script initializes the Pixi environment with Node.js and AI CLI tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "  Pixi Environment Setup"
echo "======================================"
echo ""

# Check if pixi is installed
if ! command -v pixi &> /dev/null; then
    echo "❌ Error: pixi is not installed"
    echo "Please install pixi first: curl -fsSL https://pixi.sh/install.sh | sh"
    exit 1
fi

echo "✓ Pixi found: $(pixi --version)"
echo ""

# Install pixi dependencies
echo "📦 Installing Pixi dependencies (Node.js, Python)..."
pixi install

echo ""
echo "✓ Pixi dependencies installed"
echo ""

# Install AI CLI tools and Qoder
echo "🤖 Installing AI CLI tools (gemini-cli, qodo, opencode, codex, qoder, goose)..."
pixi run setup

echo ""
echo "✓ AI CLI tools installed"
echo ""

# Verify installation
echo "🔍 Verifying installation..."
echo ""
pixi run check

echo ""
echo "======================================"
echo "  Setup Complete! 🎉"
echo "======================================"
echo ""
echo "To use the environment, run:"
echo "  pixi shell"
echo ""
echo "Or run commands directly:"
echo "  pixi run node --version"
echo "  pixi run gemini-cli --help"
echo ""
echo "See pixi-default/README.md for more information."
echo ""
