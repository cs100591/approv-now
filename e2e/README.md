# Approve Now - E2E Tests

End-to-end testing suite using Playwright for the Approve Now Flutter web app.

## Test Coverage

### ✅ Login Tests
- Valid credentials login (User 1 & User 2)
- Invalid credentials error handling

### ✅ Invite Code Tests  
- Generate invite code as workspace owner
- Validate invite code functionality
- Join workspace with invite code

### ✅ Workspace Switch Tests
- Switch workspace updates dashboard
- Dashboard stats load correctly
- Quick actions are functional

## Test Accounts

```javascript
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
```

## Installation

```bash
cd e2e
npm install
npx playwright install chromium
```

## Running Tests

### Run all tests
```bash
npm test
```

### Run specific test suites
```bash
npm run test:login      # Login tests only
npm run test:invite     # Invite code tests only
npm run test:workspace  # Workspace switch tests only
```

### Run with UI mode (for debugging)
```bash
npm run test:ui
```

### Run with browser visible
```bash
npm run test:headed
```

### Debug mode
```bash
npm run test:debug
```

## Test Reports

After running tests, view the HTML report:
```bash
npm run report
```

## Project Structure

```
e2e/
├── playwright.config.js       # Playwright configuration
├── package.json               # Node dependencies
├── tests/
│   ├── login.spec.js          # Login tests
│   ├── invite-code.spec.js    # Invite code tests
│   ├── workspace-switch.spec.js # Workspace switch tests
│   └── all.spec.js            # Global configuration
└── screenshots/               # Screenshots on failure
```

## Configuration

### Environment Variables

- `BASE_URL` - Base URL of the app (default: http://localhost:8080)
- `CI` - Set to true for CI mode (parallel tests disabled)

Example:
```bash
BASE_URL=http://localhost:3000 npm test
```

### Web Server

The tests automatically start the Flutter web server on port 8080:
```bash
flutter run -d web-server --web-port 8080
```

If you want to run tests against an already running server:
```bash
REUSE_SERVER=true npm test
```

## Writing New Tests

1. Create a new file in `tests/` directory
2. Use the test pattern:

```javascript
const { test, expect } = require('@playwright/test');

test('your test name', async ({ page }) => {
  await page.goto('/');
  // Your test steps
  await expect(page.locator('text=Expected')).toBeVisible();
});
```

## Troubleshooting

### Tests timing out
- Increase timeout in `playwright.config.js`
- Check if Flutter app is building properly

### Screenshots not saving
- Ensure `e2e/screenshots/` directory exists
- Check write permissions

### Browser not launching
- Run `npx playwright install` to install browsers

## CI/CD Integration

For GitHub Actions:

```yaml
- name: Run Playwright tests
  run: |
    cd e2e
    npm ci
    npx playwright install chromium
    npm test
```

## Notes

- Tests use a 30-second timeout for page loads
- Screenshots are taken on test failures
- Videos are recorded on first retry
- Console errors are logged for debugging
