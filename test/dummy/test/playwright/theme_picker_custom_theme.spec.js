const { test, expect } = require('@playwright/test')

test('theme picker applies and restores a custom host-app theme', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/demo/buttons', { waitUntil: 'networkidle' })

  await page.getByRole('button', { name: 'Theme' }).click()
  await page.getByRole('menuitem', { name: 'Sunrise' }).click()

  await expect(page.locator('html')).toHaveAttribute('data-theme', 'sunrise')
  await expect(page.getByRole('button', { name: 'Sunrise' })).toBeVisible()

  const appliedPrimary = await page.evaluate(() => {
    return getComputedStyle(document.documentElement).getPropertyValue('--color-primary').trim()
  })

  expect(appliedPrimary).toBe('oklch(0.68 0.19 35)')

  await page.reload({ waitUntil: 'networkidle' })

  await expect(page.locator('html')).toHaveAttribute('data-theme', 'sunrise')
  await expect(page.getByRole('button', { name: 'Sunrise' })).toBeVisible()
})