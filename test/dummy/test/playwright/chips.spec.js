const { test } = require('playwright/test')

test('chips default and interactions', async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 2200 })
  await page.goto('https://super-space-doodle-wjvwjx5rx6f5pvv-3000.app.github.dev/demo/chips', { waitUntil: 'networkidle' })

  await page.screenshot({ path: 'test-results/chips/chips-default.png', fullPage: true })

  await page.getByRole('button', { name: 'Residential' }).first().click()
  await page.screenshot({ path: 'test-results/chips/chips-interaction-toggle.png', fullPage: true })

  await page.getByRole('button', { name: /Remove Residential/i }).first().click()
  await page.waitForTimeout(300)
  await page.screenshot({ path: 'test-results/chips/chips-removal-state.png', fullPage: true })
})
