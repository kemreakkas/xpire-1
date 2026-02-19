import { test, expect } from '@playwright/test';

/**
 * Wait for Flutter web app to be ready.
 */
async function waitForAppReady(page: import('@playwright/test').Page, timeout = 60_000) {
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

/**
 * Kullanıcı akışı testleri: Bir kullanıcının yapması gereken adımlar.
 * Build alındıktan sonra bu testler otomatik koşar.
 */
test.describe('Kullanıcı akışı (User journey)', () => {
  test('1. Uygulama açılır ve ilk sayfa yüklenir', async ({ page }) => {
    await page.goto('/');
    await waitForAppReady(page);
    await expect(page).toHaveURL(/\/(login|dashboard|register)?$/);
  });

  test('2. Giriş sayfasına gidilir', async ({ page }) => {
    await page.goto('/login');
    await waitForAppReady(page);
    await expect(page).toHaveURL('/login');
  });

  test('3. Kayıt sayfasına gidilir', async ({ page }) => {
    await page.goto('/register');
    await waitForAppReady(page);
    await expect(page).toHaveURL(/\/(register|login|dashboard)?$/);
  });

  test('4. Ana sayfa (dashboard) açılır', async ({ page }) => {
    await page.goto('/dashboard');
    await waitForAppReady(page);
    await expect(page).toHaveURL('/dashboard');
  });

  test('5. Maceralar sayfası açılır', async ({ page }) => {
    await page.goto('/challenges');
    await waitForAppReady(page);
    await expect(page).toHaveURL(/\/challenges/);
  });

  test('6. İstatistikler sayfası açılır', async ({ page }) => {
    await page.goto('/stats');
    await waitForAppReady(page);
    await expect(page).toHaveURL('/stats');
  });

  test('7. Profil sayfası açılır', async ({ page }) => {
    await page.goto('/profile');
    await waitForAppReady(page);
    await expect(page).toHaveURL('/profile');
  });

  test('8. Sayfa yenilenince 404 olmaz (SPA)', async ({ page }) => {
    await page.goto('/challenges');
    await waitForAppReady(page);
    await page.reload();
    await expect(page).toHaveURL(/\/challenges/);
    await waitForAppReady(page);
  });

  test('9. Web geniş ekranda sidebar ile gezinme (URL)', async ({ page }) => {
    await page.setViewportSize({ width: 1200, height: 800 });
    await page.goto('/dashboard');
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
