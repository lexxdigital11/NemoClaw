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

## Quick Start Script

Run the quick start script for a checklist and environment verification:

```bash
./quick_start.sh
```

## Documentation

For detailed setup instructions, see [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md).