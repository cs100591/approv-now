const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ 
    headless: false, 
    slowMo: 300,
    channel: 'chrome'
  });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log('🚀 Starting test...');
    
    // Navigate to app
    await page.goto('http://localhost:8080');
    console.log('✅ Navigation started');
    
    // Wait for Flutter to initialize
    console.log('⏳ Waiting for Flutter app to initialize...');
    await page.waitForTimeout(10000);
    
    // Take screenshot
    await page.screenshot({ path: 'test-screenshots/01-after-load.png', fullPage: true });
    console.log('📸 Screenshot saved: 01-after-load.png');

    // Get page content
    const content = await page.content();
    console.log('\n📄 Page loaded, checking for Flutter canvas...');
    
    // Check if Flutter canvas exists
    const fltCanvas = await page.$('flt-glass-pane');
    if (fltCanvas) {
      console.log('✅ Flutter app is rendering');
    } else {
      console.log('⚠️ Flutter canvas not found yet, waiting more...');
      await page.waitForTimeout(5000);
      await page.screenshot({ path: 'test-screenshots/02-waiting.png', fullPage: true });
    }

    // Look for any text on the page
    const bodyText = await page.textContent('body');
    console.log('\n📋 Visible text on page:');
    console.log(bodyText.trim().substring(0, 1000));

    // Look for specific elements
    const emailInput = await page.$('input[type="email"]');
    const passwordInput = await page.$('input[type="password"]');
    const signInBtn = await page.$('button:has-text("Sign"), button:has-text("sign")');
    
    console.log('\n🔍 Found elements:');
    console.log('  Email input:', !!emailInput);
    console.log('  Password input:', !!passwordInput);
    console.log('  Sign in button:', !!signInBtn);

    if (emailInput && passwordInput) {
      console.log('\n📝 Filling in login form...');
      await emailInput.fill('test@example.com');
      await passwordInput.fill('password123');
      await page.screenshot({ path: 'test-screenshots/03-form-filled.png', fullPage: true });
      
      if (signInBtn) {
        console.log('🔘 Clicking sign in...');
        await signInBtn.click();
        await page.waitForTimeout(10000);
        await page.screenshot({ path: 'test-screenshots/04-after-login.png', fullPage: true });
      }
    }

    // Final content check
    const finalText = await page.textContent('body');
    console.log('\n📋 Final page content:');
    console.log(finalText.trim().substring(0, 1000));

    console.log('\n✅ Test complete! Browser will stay open for 30 seconds for inspection...');
    await page.waitForTimeout(30000);

  } catch (error) {
    console.error('❌ Test error:', error.message);
    await page.screenshot({ path: 'test-screenshots/error.png', fullPage: true });
    await page.waitForTimeout(5000);
  } finally {
    await browser.close();
  }
})();
