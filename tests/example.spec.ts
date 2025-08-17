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
