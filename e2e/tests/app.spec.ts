import { test, expect } from '@playwright/test';

/**
 * Wait for Flutter web app to be ready (CanvasKit or HTML renderer).
 * Flutter mounts flt-glass-pane or flutter-view; body gets flt-renderer attribute.
 */
async function waitForAppReady(page: import('@playwright/test').Page, timeout = 45_000) {
  await page.waitForLoadState('domcontentloaded');
  await page.waitForFunction(
    () => {
      const body = document.body;
      if (!body) return false;
      if (body.getAttribute('flt-renderer')) return true;
      const flt = document.querySelector('flt-glass-pane, flutter-view');
      return !!flt && flt.childElementCount > 0;
    },
    { timeout }
  );
}

test.describe('Xpire Web App', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('loads and reaches app or login URL', async ({ page }) => {
    await expect(page).toHaveURL(/\/(login|dashboard|register)?$/);
    await waitForAppReady(page);
  });

  test('login page loads', async ({ page }) => {
    await page.goto('/login');
    await expect(page).toHaveURL('/login');
    await waitForAppReady(page);
  });

  test('register page loads', async ({ page }) => {
    await page.goto('/register');
    await expect(page).toHaveURL('/register');
    await waitForAppReady(page);
  });
});

test.describe('Web shell navigation', () => {
  test('dashboard route loads', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/dashboard');
    await waitForAppReady(page);
  });

  test('challenges route loads', async ({ page }) => {
    await page.goto('/challenges');
    await expect(page).toHaveURL(/\/challenges/);
    await waitForAppReady(page);
  });

  test('stats route loads', async ({ page }) => {
    await page.goto('/stats');
    await expect(page).toHaveURL('/stats');
    await waitForAppReady(page);
  });

  test('profile route loads', async ({ page }) => {
    await page.goto('/profile');
    await expect(page).toHaveURL('/profile');
    await waitForAppReady(page);
  });

  test('SPA: direct navigation to /challenges shows challenges URL', async ({ page }) => {
    await page.goto('/challenges');
    await expect(page).toHaveURL(/\/challenges/);
    await waitForAppReady(page);
  });
});

test.describe('SPA routing', () => {
  test('404 fallback: refresh on /challenges serves app and keeps path', async ({ page }) => {
    await page.goto('/challenges');
    await expect(page).toHaveURL(/\/challenges/);
    await waitForAppReady(page);
    await page.reload();
    await expect(page).toHaveURL(/\/challenges/);
    await waitForAppReady(page);
  });
});

test.describe('Sidebar navigation (web wide)', () => {
  test.use({ viewport: { width: 1200, height: 800 } });

  test('navigates between shell routes by URL', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/dashboard');
    await waitForAppReady(page);

    await page.goto('/challenges');
    await expect(page).toHaveURL(/\/challenges/);

    await page.goto('/stats');
    await expect(page).toHaveURL('/stats');

    await page.goto('/profile');
    await expect(page).toHaveURL('/profile');

    await page.goto('/dashboard');
    await expect(page).toHaveURL('/dashboard');
  });
});
