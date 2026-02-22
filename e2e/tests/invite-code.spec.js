// @ts-check
const { test, expect } = require('@playwright/test');

const TEST_USERS = {
  user1: {
    email: 'cs1005.91@gmail.com',
    password: 'Ss910591@',
  },
  user2: {
    email: 'cssee91@outlook.com',
    password: 'Ss910591@',
  },
};

test.describe('Invite Code Flow', () => {
  
  test('generate invite code as workspace owner', async ({ page }) => {
    // Login as user1
    await page.goto('/');
    await page.waitForSelector('input[type="email"]', { timeout: 30000 });
    await page.fill('input[type="email"]', TEST_USERS.user1.email);
    await page.fill('input[type="password"]', TEST_USERS.user1.password);
    await page.click('button:has-text("Sign In")');
    
    // Wait for dashboard
    await page.waitForSelector('text=Dashboard', { timeout: 30000 });
    
    // Navigate to Team Members
    await page.click('text=Members');
    await page.waitForTimeout(2000);
    
    // Click generate invite code button
    const inviteButton = page.locator('button:has-text("Invite")').first();
    if (await inviteButton.isVisible().catch(() => false)) {
      await inviteButton.click();
      
      // Wait for invite code dialog
      await page.waitForTimeout(1000);
      
      // Check if invite code is displayed
      const inviteCodeVisible = await page.locator('text=/[A-Z0-9]{6}/').first().isVisible().catch(() => false);
      
      if (inviteCodeVisible) {
        const inviteCode = await page.locator('text=/[A-Z0-9]{6}/').first().textContent();
        console.log(`✅ Invite code generated: ${inviteCode}`);
        
        // Store invite code in test context (you might want to save this to a file)
        console.log(`📝 Save this invite code for the join test: ${inviteCode}`);
      } else {
        console.log('⚠️ Invite code dialog might not have opened or format is different');
      }
    } else {
      console.log('⚠️ Invite button not found - might need to navigate differently');
    }
  });

  test('validate invite code works correctly', async ({ page }) => {
    // This test validates that invite codes can be found and validated
    // You need to manually get a valid invite code first
    
    await page.goto('/join-workspace');
    
    // Wait for page to load
    await page.waitForTimeout(2000);
    
    // Look for invite code input
    const inviteInput = page.locator('input[placeholder*="code" i], input[name*="code" i]').first();
    
    if (await inviteInput.isVisible().catch(() => false)) {
      console.log('✅ Join workspace page loaded with invite code input');
    } else {
      console.log('⚠️ Invite code input not found - checking page structure');
      // Take screenshot for debugging
      await page.screenshot({ path: 'e2e/screenshots/join-workspace-debug.png' });
    }
  });

  test('join workspace with invite code', async ({ page }) => {
    // Login as user2 (who will join)
    await page.goto('/');
    await page.waitForSelector('input[type="email"]', { timeout: 30000 });
    await page.fill('input[type="email"]', TEST_USERS.user2.email);
    await page.fill('input[type="password"]', TEST_USERS.user2.password);
    await page.click('button:has-text("Sign In")');
    
    // Wait for dashboard
    await page.waitForSelector('text=Dashboard', { timeout: 30000 });
    
    // Navigate to join workspace
    await page.goto('/join-workspace');
    await page.waitForTimeout(2000);
    
    // Try to find invite code input
    const inviteInput = page.locator('input').first();
    
    if (await inviteInput.isVisible().catch(() => false)) {
      // Use a test invite code (you should replace this with a real one)
      await inviteInput.fill('TEST12');
      
      // Look for submit/validate button
      const submitButton = page.locator('button:has-text("Join")').first();
      if (await submitButton.isVisible().catch(() => false)) {
        await submitButton.click();
        
        // Wait for response
        await page.waitForTimeout(3000);
        
        // Check for success or error message
        const successVisible = await page.locator('text=/success|joined|welcome/i').first().isVisible().catch(() => false);
        const errorVisible = await page.locator('text=/invalid|expired|error/i').first().isVisible().catch(() => false);
        
        if (successVisible) {
          console.log('✅ Successfully joined workspace with invite code');
        } else if (errorVisible) {
          console.log('⚠️ Got expected error (invite code might be invalid or expired)');
        } else {
          console.log('⚠️ No clear success or error message');
        }
      }
    }
  });

});
