const { test, expect } = require('@playwright/test')

test('theme picker applies and restores a custom host-app theme', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/demo/buttons', { waitUntil: 'networkidle' })

  const themeController = page.locator('[data-controller="flat-pack--theme"]').first()
  const themeTrigger = themeController.locator('[data-flat-pack--button-dropdown-target="trigger"]')

  await themeTrigger.click()
  await page.locator('[role="menu"][aria-hidden="false"]').getByRole('menuitem', { name: 'Sunrise' }).click()

  await expect(page.locator('html')).toHaveAttribute('data-theme', 'sunrise')
  await expect(themeTrigger).toContainText('Sunrise')

  const primaryRgb = await page.locator('.bg-\\[var\\(--color-primary\\)\\]').first().evaluate((el) => getComputedStyle(el).backgroundColor)
  const rgb = primaryRgb.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/)
  expect(rgb, `expected a computed rgb primary, got ${primaryRgb}`).not.toBeNull()
  const [red, green, blue] = rgb.slice(1, 4).map(Number)
  expect(red).toBeGreaterThan(green)
  expect(red).toBeGreaterThan(blue)
})