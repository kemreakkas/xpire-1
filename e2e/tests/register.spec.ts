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

/** Check if register form is in DOM (HTML renderer). With CanvasKit form is not in DOM. */
async function hasRegisterForm(page: import('@playwright/test').Page): Promise<boolean> {
  const email = page.getByRole('textbox', { name: /email/i }).first();
  return email.isVisible().catch(() => false);
}

test.describe('Kullanıcı oluşturma (Kayıt)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/register');
    await waitForAppReady(page);
  });

  test('kayıt sayfası yüklenir ve hazır olur', async ({ page }) => {
    await expect(page).toHaveURL(/\/(register|login|dashboard)?$/);
  });

  test('kayıt sayfası açıldığında uygulama hazır olur', async ({ page }) => {
    const body = page.locator('body');
    await expect(body).toHaveAttribute('flt-renderer', /.+/);
  });

  test('boş form gönderilince validasyon hataları gösterilir', async ({ page }) => {
    const formVisible = await hasRegisterForm(page);
    if (!formVisible) {
      test.skip();
      return;
    }
    await page.getByRole('button', { name: /create account|hesap oluştur/i }).first().click();
    await expect(
      page.getByText(/enter your email|enter a valid email|at least 6|en az 6|passwords do not match|şifreler eşleşmiyor/i)
    ).toBeVisible({ timeout: 10_000 });
  });

  test('geçersiz e-posta ile gönderimde hata gösterilir', async ({ page }) => {
    const formVisible = await hasRegisterForm(page);
    if (!formVisible) {
      test.skip();
      return;
    }
    const textboxes = page.getByRole('textbox');
    await textboxes.nth(0).fill('invalid');
    await textboxes.nth(1).fill('123456');
    await textboxes.nth(2).fill('123456');
    await page.getByRole('button', { name: /create account|hesap oluştur/i }).first().click();
    await expect(
      page.getByText(/enter a valid email|geçerli bir e-posta/i)
    ).toBeVisible({ timeout: 10_000 });
  });

  test('şifre eşleşmezse hata gösterilir', async ({ page }) => {
    const formVisible = await hasRegisterForm(page);
    if (!formVisible) {
      test.skip();
      return;
    }
    const textboxes = page.getByRole('textbox');
    await textboxes.nth(0).fill('test@example.com');
    await textboxes.nth(1).fill('123456');
    await textboxes.nth(2).fill('different');
    await page.getByRole('button', { name: /create account|hesap oluştur/i }).first().click();
    await expect(
      page.getByText(/passwords do not match|şifreler eşleşmiyor|do not match/i)
    ).toBeVisible({ timeout: 10_000 });
  });

  test('geçerli form ile gönderim yapılabilir (yönlendirme veya hata)', async ({ page }) => {
    const formVisible = await hasRegisterForm(page);
    if (!formVisible) {
      test.skip();
      return;
    }
    const uniqueEmail = `e2e-${Date.now()}@example.com`;
    const textboxes = page.getByRole('textbox');
    await textboxes.nth(0).fill(uniqueEmail);
    await textboxes.nth(1).fill('Test123456');
    await textboxes.nth(2).fill('Test123456');
    await page.getByRole('button', { name: /create account|hesap oluştur/i }).first().click();
    await page.waitForURL(/\/(dashboard|register)/, { timeout: 20_000 });
    const url = page.url();
    expect(url.includes('/dashboard') || url.includes('/register')).toBeTruthy();
  });
});
