#!/bin/bash

# Quick Start Script for NemoClaw
# This script helps you get started quickly with NemoClaw setup

set -e

echo "🚀 NemoClaw Quick Start"
echo "======================"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from the root of your NemoClaw repository"
    exit 1
fi

# Check if required files exist
required_files=(
    ".devcontainer/devcontainer.json"
    "scripts/setup.sh"
    "requirements.txt"
    "nemo_claw.py"
)

echo "📋 Checking required files..."
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - Missing!"
        exit 1
    fi
done

echo ""
echo "🔧 Environment Setup"
echo "===================="

# Check if environment variables are set
if [ -z "$NVIDIA_API_KEY" ]; then
    echo "⚠️  NVIDIA_API_KEY not set"
    echo "   Please set: export NVIDIA_API_KEY='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'"
else
    echo "✅ NVIDIA_API_KEY is set"
fi

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "⚠️  TELEGRAM_BOT_TOKEN not set"
    echo "   Please set: export TELEGRAM_BOT_TOKEN='8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k'"
else
    echo "✅ TELEGRAM_BOT_TOKEN is set"
fi

if [ -z "$AGENT_NAME" ]; then
    echo "⚠️  AGENT_NAME not set"
    echo "   Please set: export AGENT_NAME='claudy'"
else
    echo "✅ AGENT_NAME is set"
fi

echo ""
echo "💡 Next Steps"
echo "============="

if [ -z "$NVIDIA_API_KEY" ] || [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$AGENT_NAME" ]; then
    echo "1. Set your environment variables:"
    echo "   export NVIDIA_API_KEY='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'"
    echo "   export TELEGRAM_BOT_TOKEN='8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k'"
    echo "   export AGENT_NAME='claudy'"
    echo ""
fi

echo "2. Push to GitHub:"
echo "   git add ."
echo "   git commit -m 'Add NemoClaw setup'"
echo "   git push origin main"
echo ""
echo "3. Open in GitHub Codespaces:"
echo "   - Go to your GitHub repository"
echo "   - Click 'Code' → 'Codespaces' → 'New codespace'"
echo ""
echo "4. Start NemoClaw:"
echo "   python3 nemo_claw.py"
echo ""

# Check if we can run the setup script
if [ -x "scripts/setup.sh" ]; then
    echo "🧪 You can also test the setup locally (not recommended):"
    echo "   bash scripts/setup.sh"
    echo ""
fi

echo "📖 For detailed instructions, see: docs/SETUP_GUIDE.md"
echo ""
echo "🎯 Ready to go! Use GitHub Codespaces for the best experience."