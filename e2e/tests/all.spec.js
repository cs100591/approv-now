// @ts-check
/**
 * Main test suite for Approve Now
 * 
 * This file contains global test configuration
 */

const { test } = require('@playwright/test');

// Global test configuration
test.beforeEach(async ({ page }) => {
  // Set viewport size
  await page.setViewportSize({ width: 1280, height: 720 });
  
  // Add console logging for debugging
  page.on('console', msg => {
    if (msg.type() === 'error') {
      console.error(`❌ Console error: ${msg.text()}`);
    }
  });
  
  page.on('pageerror', error => {
    console.error(`❌ Page error: ${error.message}`);
  });
});

test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== testInfo.expectedStatus) {
    // Take screenshot on failure
    await page.screenshot({ 
      path: `e2e/screenshots/${testInfo.title.replace(/\s+/g, '_')}.png`,
      fullPage: true 
    });
  }
});
