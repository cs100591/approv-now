// @ts-check
const { test, expect } = require('@playwright/test');

// Test credentials
const TEST_USERS = {
  user1: {
    email: 'cs1005.91@gmail.com',
    password: 'Ss910591@',
  },
};

test.describe('Critical Bug Fixes Verification', () => {
  
  test('app loads successfully', async ({ page }) => {
    await page.goto('/');
    
    // Wait for app to render
    await page.waitForTimeout(5000);
    
    // Take screenshot for verification
    await page.screenshot({ path: 'e2e/screenshots/app-loaded.png' });
    
    // Check if login form is visible
    const emailLabel = await page.locator('text=Email').first().isVisible().catch(() => false);
    const passwordLabel = await page.locator('text=Password').first().isVisible().catch(() => false);
    
    expect(emailLabel || passwordLabel).toBeTruthy();
    
    console.log('✅ App loaded successfully');
  });

  test('login form can be filled', async ({ page }) => {
    await page.goto('/');
    
    // Wait for app to render
    await page.waitForTimeout(5000);
    
    // Fill email
    const emailInput = page.locator('input').first();
    await emailInput.fill(TEST_USERS.user1.email);
    
    // Fill password
    const inputs = await page.locator('input').all();
    if (inputs.length >= 2) {
      await inputs[1].fill(TEST_USERS.user1.password);
    }
    
    // Take screenshot
    await page.screenshot({ path: 'e2e/screenshots/login-filled.png' });
    
    console.log('✅ Login form filled successfully');
  });

  test('can click sign in button', async ({ page }) => {
    await page.goto('/');
    
    // Wait for app to render
    await page.waitForTimeout(5000);
    
    // Fill form
    const emailInput = page.locator('input').first();
    await emailInput.fill(TEST_USERS.user1.email);
    
    const inputs = await page.locator('input').all();
    if (inputs.length >= 2) {
      await inputs[1].fill(TEST_USERS.user1.password);
    }
    
    // Click sign in
    await page.click('button:has-text("Sign In")');
    
    // Wait for response
    await page.waitForTimeout(3000);
    
    // Take screenshot
    await page.screenshot({ path: 'e2e/screenshots/after-signin.png' });
    
    console.log('✅ Sign in button clicked');
  });

});
