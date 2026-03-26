# NemoClaw Setup Guide

This guide walks you through setting up NemoClaw in GitHub Codespaces to avoid local installation issues.

## Why GitHub Codespaces?

GitHub Codespaces provides a cloud-based development environment that:
- Eliminates local dependency conflicts
- Ensures consistent environment across all users
- Handles complex AI model dependencies automatically
- Provides pre-configured development tools
- Avoids NVIDIA driver and CUDA installation issues

## Prerequisites

1. **GitHub Account** - You need a GitHub account with Codespaces access
2. **NVIDIA API Key** - Your NVIDIA API key: `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`
3. **Telegram Bot Token** - Your Telegram bot token: `8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k`
4. **Agent Name** - Your agent name: `claudy`

## Step-by-Step Setup

### Step 1: Create GitHub Repository

1. Create a new repository on GitHub (or use an existing one)
2. Push the NemoClaw setup files to your repository:
   ```bash
   git init
   git add .
   git commit -m "Initial NemoClaw setup"
   git branch -M main
   git remote add origin https://github.com/yourusername/nemo-claw.git
   git push -u origin main
   ```

### Step 2: Configure Environment Variables

1. Go to your GitHub repository
2. Click on **Settings** → **Codespaces** → **Environment variables**
3. Add the following environment variables:

   | Variable Name | Value | Description |
   |---------------|-------|-------------|
   | `NVIDIA_API_KEY` | `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` | Your NVIDIA API key |
   | `TELEGRAM_BOT_TOKEN` | `8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k` | Your Telegram bot token |
   | `AGENT_NAME` | `claudy` | Your agent's name |

4. Set the **Repository** scope for these variables

### Step 3: Open in GitHub Codespaces

1. In your repository, click the **Code** button
2. Select the **Codespaces** tab
3. Click **New codespace**
4. Wait for the Codespace to initialize (this may take 2-5 minutes)

### Step 4: Automatic Setup

The Codespace will automatically:
1. Install all required dependencies
2. Configure the NVIDIA AI Foundation Model SDK
3. Set up the Telegram bot integration
4. Create the configuration files

You'll see the setup progress in the terminal.

### Step 5: Start NemoClaw

Once the setup is complete, run:

```bash
python3 nemo_claw.py
```

## Manual Configuration (Optional)

If you need to manually configure or modify settings:

### Configuration File Location
`~/.nemo_claw/config.yaml`

### Example Configuration
```yaml
# NemoClaw Configuration
agent_name: "claudy"

# NVIDIA API Configuration
nvidia:
  api_key: "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"
  base_url: "https://api.nvidia.com/v1"

# Telegram Bot Configuration
telegram:
  bot_token: "8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k"
  allowed_users: []  # Add user IDs that can interact with the bot

# Logging Configuration
logging:
  level: "INFO"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Development Settings
development:
  debug: false
  verbose: false
```

## Testing Your Setup

### Test NVIDIA API Connection
```bash
python3 -c "
from nvidia_ai_foundation_models import NVIDIAFoundationModelClient
client = NVIDIAFoundationModelClient(api_key='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')
print('✅ NVIDIA API connection successful')
"
```

### Test Telegram Bot
1. Start the bot: `python3 nemo_claw.py`
2. Open Telegram and search for your bot
3. Send `/start` to test the connection
4. Send `/status` to check the bot status

## Troubleshooting

### Common Issues

#### 1. NVIDIA API Key Not Working
- Verify your API key is correct
- Check if your NVIDIA account has API access enabled
- Ensure the key has the necessary permissions

#### 2. Telegram Bot Not Responding
- Verify your bot token is correct
- Check if the bot is active in Telegram
- Ensure the bot token is set in environment variables

#### 3. Dependencies Installation Fails
- The Codespace environment should handle this automatically
- If issues persist, try restarting the Codespace

#### 4. Configuration File Not Found
- The setup script creates this automatically
- Check `~/.nemo_claw/config.yaml` exists
- Verify environment variables are set correctly

### Getting Help

1. Check the logs in the terminal for error messages
2. Verify all environment variables are set correctly
3. Ensure you're in the correct directory (`/workspaces/your-repo-name`)
4. Try restarting the Codespace if issues persist

## Advanced Configuration

### Adding Allowed Users (Telegram Security)
To restrict bot access to specific users:

1. Get your Telegram user ID by messaging @userinfobot
2. Add the user ID to the `allowed_users` list in `config.yaml`:

```yaml
telegram:
  bot_token: "8296887064:AAFDXxk_-GZEys0sfZ02LpLwW3N0-eJMR8k"
  allowed_users: 
    - 123456789  # Your user ID
    - 987654321  # Another authorized user
```

### Customizing AI Model
You can change the NVIDIA model used for responses:

```yaml
nvidia:
  api_key: "your-api-key"
  model: "nvidia/llama-3.1-nemotron-70b-instruct"  # Change this model
```

### Development Mode
Enable debug logging for troubleshooting:

```yaml
development:
  debug: true
  verbose: true
```

## Security Notes

1. **Never commit API keys** to your repository
2. **Use environment variables** for sensitive information
3. **Restrict Telegram bot access** to authorized users only
4. **Monitor API usage** to avoid unexpected charges

## Next Steps

Once your setup is complete:
1. Test all functionality thoroughly
2. Customize the agent's behavior as needed
3. Consider adding additional features or integrations
4. Monitor usage and performance

## Support

If you encounter issues:
1. Check this documentation first
2. Review the troubleshooting section
3. Check the terminal logs for specific error messages
4. Consider creating a new Codespace if issues persist

The GitHub Codespaces approach should eliminate most local installation issues you might encounter with AI agents and complex dependencies.