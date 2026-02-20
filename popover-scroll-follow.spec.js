const { test, expect } = require('@playwright/test')

test('popover follows trigger while scrolling', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/demo/popovers')

  const trigger = page.locator('#popover-trigger-basic')
  const popover = page.locator('[data-flat-pack--popover-trigger-id-value="popover-trigger-basic"]')

  await trigger.click()
  await expect(popover).toBeVisible()

  const before = await page.evaluate(() => {
    const triggerRect = document.getElementById('popover-trigger-basic').getBoundingClientRect()
    const popoverRect = document.querySelector('[data-flat-pack--popover-trigger-id-value="popover-trigger-basic"]').getBoundingClientRect()

    return {
      dx: popoverRect.left - triggerRect.left,
      dy: popoverRect.top - triggerRect.bottom
    }
  })

  await page.screenshot({ path: '/tmp/popover-before-scroll.png' })

  await page.evaluate(() => window.scrollBy(0, 500))
  await page.waitForTimeout(100)

  const after = await page.evaluate(() => {
    const triggerRect = document.getElementById('popover-trigger-basic').getBoundingClientRect()
    const popoverRect = document.querySelector('[data-flat-pack--popover-trigger-id-value="popover-trigger-basic"]').getBoundingClientRect()

    return {
      dx: popoverRect.left - triggerRect.left,
      dy: popoverRect.top - triggerRect.bottom
    }
  })

  await page.screenshot({ path: '/tmp/popover-after-scroll.png' })

  expect(Math.abs(after.dx - before.dx)).toBeLessThan(2)
  expect(Math.abs(after.dy - before.dy)).toBeLessThan(2)
})
