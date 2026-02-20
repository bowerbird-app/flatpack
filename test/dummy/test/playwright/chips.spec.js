const { test } = require('@playwright/test')

test('chips default and interactions', async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 2200 })
  await page.goto('http://127.0.0.1:3000/demo/chips', { waitUntil: 'networkidle' })

  await page.screenshot({ path: 'test-results/chips/chips-default.png', fullPage: true })

  await page.getByRole('button', { name: 'Active' }).first().click()
  await page.screenshot({ path: 'test-results/chips/chips-interaction-toggle.png', fullPage: true })

  await page.locator('#removable-chips-container button[aria-label="Remove"]').first().click()
  await page.waitForTimeout(300)
  await page.screenshot({ path: 'test-results/chips/chips-removal-state.png', fullPage: true })
})
