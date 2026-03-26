#!/bin/bash

# NemoClaw Setup Script for GitHub Codespaces
# This script installs NemoClaw and configures the environment

set -e

echo "🚀 Starting NemoClaw installation in GitHub Codespaces..."

# Check if required environment variables are set
if [ -z "$NVIDIA_API_KEY" ]; then
    echo "⚠️  Warning: NVIDIA_API_KEY not set. Please set it in your Codespace settings."
    echo "   Add: NVIDIA_API_KEY=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"
fi

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "⚠️  Warning: TELEGRAM_BOT_TOKEN not set. Please set it in your Codespace settings."
    echo "   Add: TELEGRAM_BOT_TOKEN=8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k"
fi

if [ -z "$AGENT_NAME" ]; then
    echo "⚠️  Warning: AGENT_NAME not set. Please set it in your Codespace settings."
    echo "   Add: AGENT_NAME=claudy"
fi

# Update package lists
echo "📦 Updating package lists..."
apt-get update

# Install system dependencies
echo "🔧 Installing system dependencies..."
apt-get install -y \
    curl \
    wget \
    git \
    python3-pip \
    python3-venv \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev

# Create Python virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install NemoClaw and dependencies
echo "📦 Installing NemoClaw and dependencies..."
pip install --upgrade pip setuptools wheel

# Install core dependencies
pip install \
    requests \
    aiohttp \
    python-telegram-bot \
    pyyaml \
    python-dotenv \
    rich \
    typer

# Install NVIDIA AI Foundation Model SDK
echo "🤖 Installing NVIDIA AI Foundation Model SDK..."
pip install nvidia-ai-foundation-models

# Create configuration directory
mkdir -p ~/.nemo_claw

# Create default configuration
cat > ~/.nemo_claw/config.yaml << EOF
# NemoClaw Configuration
agent_name: "${AGENT_NAME:-claudy}"

# NVIDIA API Configuration
nvidia:
  api_key: "${NVIDIA_API_KEY:-}"
  base_url: "https://api.nvidia.com/v1"

# Telegram Bot Configuration
telegram:
  bot_token: "${TELEGRAM_BOT_TOKEN:-}"
  allowed_users: []  # Add user IDs that can interact with the bot

# Logging Configuration
logging:
  level: "INFO"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Development Settings
development:
  debug: false
  verbose: false
EOF

# Create NemoClaw main application
cat > nemo_claw.py << 'EOF'
#!/usr/bin/env python3
"""
NemoClaw - AI Agent with NVIDIA API and Telegram Integration
"""

import os
import yaml
import logging
import asyncio
from pathlib import Path
from typing import Dict, Any
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from nvidia_ai_foundation_models import NVIDIAFoundationModelClient

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class NemoClaw:
    def __init__(self, config_path: str = "~/.nemo_claw/config.yaml"):
        self.config_path = Path(config_path).expanduser()
        self.config = self.load_config()
        self.agent_name = self.config.get('agent_name', 'claudy')
        
        # Initialize NVIDIA client
        self.nvidia_client = None
        if self.config['nvidia'].get('api_key'):
            self.nvidia_client = NVIDIAFoundationModelClient(
                api_key=self.config['nvidia']['api_key'],
                base_url=self.config['nvidia'].get('base_url', 'https://api.nvidia.com/v1')
            )
        
        logger.info(f"🤖 NemoClaw initialized with agent name: {self.agent_name}")

    def load_config(self) -> Dict[str, Any]:
        """Load configuration from YAML file"""
        if not self.config_path.exists():
            logger.warning(f"Config file not found at {self.config_path}")
            return {}
        
        with open(self.config_path, 'r') as f:
            return yaml.safe_load(f) or {}

    async def start_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /start command"""
        await update.message.reply_text(
            f"👋 Hello! I'm {self.agent_name}, your AI assistant powered by NVIDIA AI Foundation Models.\n"
            "Send me a message and I'll help you with it!"
        )

    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /help command"""
        await update.message.reply_text(
            "🆘 Available commands:\n"
            "/start - Start the bot\n"
            "/help - Show this help message\n"
            "/status - Show bot status\n"
            "\nJust send me any message and I'll respond using NVIDIA AI!"
        )

    async def status_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /status command"""
        status = "✅ Active" if self.nvidia_client else "⚠️ NVIDIA API not configured"
        await update.message.reply_text(
            f"🤖 Agent: {self.agent_name}\n"
            f"📡 Status: {status}\n"
            f"🔧 NVIDIA API: {'Configured' if self.nvidia_client else 'Not configured'}"
        )

    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle incoming messages"""
        user_message = update.message.text
        user_id = update.message.from_user.id
        
        logger.info(f"📨 Received message from user {user_id}: {user_message[:50]}...")
        
        # Check if user is allowed
        allowed_users = self.config.get('telegram', {}).get('allowed_users', [])
        if allowed_users and user_id not in allowed_users:
            await update.message.reply_text("❌ You are not authorized to use this bot.")
            return

        # Generate response using NVIDIA AI
        try:
            if self.nvidia_client:
                response = await self.generate_response(user_message)
            else:
                response = "⚠️ NVIDIA API is not configured. Please set up your NVIDIA API key."
        except Exception as e:
            logger.error(f"Error generating response: {e}")
            response = "❌ Sorry, I encountered an error while processing your request."

        await update.message.reply_text(response)

    async def generate_response(self, prompt: str) -> str:
        """Generate response using NVIDIA AI Foundation Models"""
        try:
            # Use NVIDIA AI to generate response
            response = self.nvidia_client.generate(
                model="nvidia/llama-3.1-nemotron-70b-instruct",
                prompt=prompt,
                max_tokens=1000,
                temperature=0.7
            )
            return response['text']
        except Exception as e:
            logger.error(f"Error calling NVIDIA API: {e}")
            return f"❌ Error generating response: {str(e)}"

    def run_telegram_bot(self):
        """Run the Telegram bot"""
        if not self.config.get('telegram', {}).get('bot_token'):
            logger.error("Telegram bot token not configured")
            return

        application = Application.builder().token(self.config['telegram']['bot_token']).build()
        
        # Add handlers
        application.add_handler(CommandHandler("start", self.start_command))
        application.add_handler(CommandHandler("help", self.help_command))
        application.add_handler(CommandHandler("status", self.status_command))
        application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, self.handle_message))
        
        logger.info("🚀 Starting Telegram bot...")
        application.run_polling()

def main():
    """Main entry point"""
    nemo_claw = NemoClaw()
    
    # Check if running with Telegram bot
    if nemo_claw.config.get('telegram', {}).get('bot_token'):
        nemo_claw.run_telegram_bot()
    else:
        print("🤖 NemoClaw initialized successfully!")
        print("📝 Configuration loaded from ~/.nemo_claw/config.yaml")
        print("🔧 NVIDIA API configured:", bool(nemo_claw.nvidia_client))
        print("📡 Telegram bot token configured:", bool(nemo_claw.config.get('telegram', {}).get('bot_token')))
        print("\nTo start the Telegram bot, ensure TELEGRAM_BOT_TOKEN is set in your environment.")

if __name__ == "__main__":
    main()
EOF

# Make scripts executable
chmod +x nemo_claw.py
chmod +x scripts/setup.sh

# Create a simple README
cat > README.md << 'EOF'
# NemoClaw - AI Agent Setup

This repository contains the setup for NemoClaw, an AI agent that integrates with NVIDIA AI Foundation Models and Telegram.

## Quick Start

### 1. Environment Variables

Set the following environment variables in your GitHub Codespace:

```bash
export NVIDIA_API_KEY="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"
export TELEGRAM_BOT_TOKEN="8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k"
export AGENT_NAME="claudy"
```

### 2. Run Setup

The setup script runs automatically when the Codespace is created, but you can also run it manually:

```bash
bash scripts/setup.sh
```

### 3. Start the Agent

```bash
python3 nemo_claw.py
```

## Configuration

The agent is configured via `~/.nemo_claw/config.yaml`. The setup script creates a default configuration with your environment variables.

## Features

- 🤖 NVIDIA AI Foundation Model integration
- 📡 Telegram bot interface
- 🔧 Easy setup in GitHub Codespaces
- 📝 YAML configuration
- 🐍 Python-based architecture

## Troubleshooting

1. **NVIDIA API Issues**: Ensure your API key is valid and has the necessary permissions
2. **Telegram Bot Issues**: Verify your bot token is correct and the bot is active
3. **Environment Variables**: Make sure all required environment variables are set in your Codespace settings

## Development

This setup is designed for GitHub Codespaces to avoid local installation issues. The containerized environment ensures consistent dependencies and configurations.
EOF

echo "✅ NemoClaw setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Set your environment variables in GitHub Codespace settings:"
echo "   - NVIDIA_API_KEY: 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"
echo "   - TELEGRAM_BOT_TOKEN: 8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k"
echo "   - AGENT_NAME: claudy"
echo ""
echo "2. Commit and push this repository to GitHub"
echo "3. Open it in GitHub Codespaces"
echo "4. The setup will run automatically"
echo "5. Start the agent with: python3 nemo_claw.py"