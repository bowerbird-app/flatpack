const { test, expect } = require('@playwright/test')

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

test('removable chip can issue a GET callback before removal', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/demo/chips', { waitUntil: 'networkidle' })

  const callbackChip = page.locator('#removable-chips-container [data-controller="flat-pack--chip"]').first()
  const callbackResponse = page.waitForResponse((response) => {
    return response.url().includes('/demo/chips/remove_callback?tag=ruby&source=chips_demo') &&
      response.request().method() === 'GET' &&
      response.status() === 200
  })

  await page.locator('#removable-chips-container button[aria-label="Remove"]').first().click()

  const response = await callbackResponse
  const payload = await response.json()
  await expect(callbackChip).toHaveCount(0)
  expect(payload).toEqual({
    ok: true,
    method: 'GET',
    params: { tag: 'ruby', source: 'chips_demo' }
  })
})
