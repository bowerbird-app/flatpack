const { test, expect } = require('@playwright/test')

test('theme picker applies and restores a custom host-app theme', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/demo/buttons', { waitUntil: 'networkidle' })

  const themeController = page.locator('[data-controller="flat-pack--theme"]').first()
  const themeTrigger = themeController.locator('[data-flat-pack--button-dropdown-target="trigger"]')

  await themeTrigger.click()
  await page.locator('[role="menu"][aria-hidden="false"]').getByRole('menuitem', { name: 'Sunrise' }).click()

  await expect(page.locator('html')).toHaveAttribute('data-theme', 'sunrise')
  await expect(themeTrigger).toContainText('Sunrise')

})