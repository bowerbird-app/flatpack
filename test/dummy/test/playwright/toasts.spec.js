const { test, expect } = require('@playwright/test')

test('toast demo buttons show toasts', async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 1600 })
  await page.goto('http://127.0.0.1:3000/demo/toasts', { waitUntil: 'networkidle' })

  await page.getByRole('button', { name: 'Info Toast' }).click()
  await expect(page.locator('[data-controller="flat-pack--toast"]')).toHaveCount(1)

  await page.getByRole('button', { name: 'Success Toast' }).click()
  await expect(page.locator('[data-controller="flat-pack--toast"]')).toHaveCount(2)

  await page.screenshot({ path: 'test-results/toasts/toasts-demo-triggered.png', fullPage: true })
})
