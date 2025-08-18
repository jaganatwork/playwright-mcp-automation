#!/bin/bash
set -e

echo "🚀 Starting Playwright MCP setup..."
echo "📍 Running in: $(pwd)"
echo "👤 User: $(whoami)"

# Update package lists
echo "📦 Updating system packages..."
apt-get update -qq

# Install virtual display for headed tests (if needed)
apt-get install -y xvfb x11-utils x11-xserver-utils

# Set up virtual display
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &


# Install required system dependencies for browsers
echo "🔧 Installing browser dependencies..."
apt-get install -y --no-install-recommends \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libgtk-3-0 \
    libasound2t64

# Create project directories
echo "📁 Creating project structure..."
# ADD: More subdirectories and force create even if they exist
mkdir -p tests tests/auth tests/api tests/e2e
mkdir -p test-results playwright-report screenshots videos traces
mkdir -p pages utils fixtures data
mkdir -p prompts manual-testing manual-testing/screenshots manual-testing/test-results

# ADD: Show what was created
echo "📂 Created directories:"
ls -d */ 2>/dev/null | head -15

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "📄 Creating package.json..."
    npm init -y
fi

# ADD: Update package.json scripts
echo "📝 Adding npm scripts..."
npm pkg set scripts.test="playwright test"
npm pkg set scripts.test:ui="playwright test --ui --host=0.0.0.0"
npm pkg set scripts.test:debug="playwright test --debug"
npm pkg set scripts.test:headed="playwright test --headed"
npm pkg set scripts.report="playwright show-report --host=0.0.0.0 --port=9323"
npm pkg set scripts.codegen="playwright codegen"

# Install Playwright
echo "🎭 Installing Playwright Test framework..."
npm install -D @playwright/test@latest

# Install browsers with dependencies
echo "🌐 Installing browsers (Chromium, Firefox, WebKit)..."
npx playwright install chromium firefox webkit
npx playwright install-deps chromium firefox webkit

# Install MCP Playwright server
npm install -g @playwright/mcp@latest

# Install additional useful packages
echo "📚 Installing additional packages..."
npm install -D @faker-js/faker typescript @types/node

# ADD: Create tsconfig.json if it doesn't exist
if [ ! -f "tsconfig.json" ]; then
    echo "📄 Creating tsconfig.json..."
    cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022", "DOM"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "types": ["node", "@playwright/test"]
  },
  "include": ["**/*.ts"],
  "exclude": ["node_modules", "test-results", "playwright-report"]
}
TSCONFIG
fi

# Create a basic playwright config if it doesn't exist
if [ ! -f "playwright.config.ts" ]; then
    echo "⚙️ Creating default playwright.config.ts..."
    cat > playwright.config.ts << 'CONFIG'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  outputDir: './test-results',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { 
      outputFolder: 'playwright-report',
      open: 'never',
      host: '0.0.0.0',
      port: 9323
    }],
    ['list']
  ],
  use: {
    baseURL: 'https://practicetestautomation.com/practice-test-login/',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    headless: true,
  },
  projects: [
    { 
      name: 'chromium', 
      use: { 
        ...devices['Desktop Chrome'],
        launchOptions: {
          args: ['--no-sandbox', '--disable-setuid-sandbox']
        }
      } 
    },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
CONFIG
fi

# ADD: Create a sample test file if tests directory is empty
if [ ! -f "tests/example.spec.ts" ]; then
    echo "📝 Creating example test..."
    cat > tests/example.spec.ts << 'TEST'
import { test, expect } from '@playwright/test';

test.describe('Example Test Suite', () => {
  test('should load the practice test login page', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Practice Test Login/);
    
    // Check login form elements
    await expect(page.locator('#username')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    await expect(page.locator('#submit')).toBeVisible();
  });
});
TEST
fi

# ADD: Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'GITIGNORE'
node_modules/
test-results/
playwright-report/
playwright/.cache/
screenshots/
videos/
traces/
.env
*.log
GITIGNORE
fi

# Verify installation
echo "✅ Verifying installation..."
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
npx playwright --version || echo "⚠️ Playwright verification failed"

npx -y @playwright/mcp@latest --version || echo "⚠️ Playwright MCP verification failed"
# Configure MCP server for VS Code in Codespaces
echo "🛠️ Configuring MCP server for VS Code in Codespaces..."
code --add-mcp '{"name":"playwright","command":"npx","args":["@playwright/mcp@latest"]}' || echo "⚠️ MCP server configuration failed"

# ADD: Final verification
echo "🔍 Final Check:"
echo "- Directories created: $(ls -d */ 2>/dev/null | wc -l)"
echo "- Test files: $(find tests -name "*.spec.ts" 2>/dev/null | wc -l)"
echo "- Browsers installed: $(ls /ms-playwright/ 2>/dev/null | wc -l)"

echo "✨ Setup complete! You can now run: npm test"
echo "📝 Try: npx playwright test --reporter=list"