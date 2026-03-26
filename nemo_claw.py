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