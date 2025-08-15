#!/bin/bash
set -e

echo "🚀 Setting up Playwright MCP environment..."

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    xvfb \
    fonts-liberation \
    libgtk-3-0 \
    libgbm-dev \
    libnotify-dev \
    libnss3 \
    libxss1 \
    libasound2 \
    xdg-utils

# Create project directories
echo "📁 Creating project directories..."
mkdir -p tests test-results playwright-report screenshots
mkdir -p pages utils fixtures data
mkdir -p prompts manual-testing

# Install Node dependencies
echo "📦 Installing Node.js dependencies..."
if [ -f "package.json" ]; then
    npm install
else
    echo "package.json not found, creating one..."
    npm init -y
fi

# Install Playwright
echo "🎭 Installing Playwright..."
npm install -D @playwright/test@latest
npx playwright install chromium firefox webkit
npx playwright install-deps

# Verify installations
echo "✅ Verifying installations..."
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
npx playwright --version

echo "✨ Setup complete! You can now:"
echo "  - Run tests: npm test"
echo "  - Use Copilot Chat for AI assistance"
echo "  - Generate tests with Playwright MCP"