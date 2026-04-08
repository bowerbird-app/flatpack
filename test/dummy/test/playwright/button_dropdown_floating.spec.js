const { test, expect } = require('@playwright/test')

test('button dropdown floats outside clipped containers', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/demo/chat/panel')

  const trigger = page.getByRole('button', { name: 'Conversation actions' })
  await trigger.click()

  const menu = page.locator('[role="menu"]').filter({ hasText: 'Search conversation' })
  await expect(menu).toBeVisible()

  const metrics = await page.evaluate(() => {
    const triggerElement = document.querySelector('button[aria-label="Conversation actions"]')
    const wrapper = triggerElement.closest('[data-controller="flat-pack--button-dropdown"]')
    const menuElement = Array.from(document.querySelectorAll('[role="menu"]')).find((element) => element.textContent.includes('Search conversation'))

    const triggerRect = triggerElement.getBoundingClientRect()
    const wrapperRect = wrapper.getBoundingClientRect()
    const menuWidth = menuElement.offsetWidth

    return {
      parentIsBody: menuElement.parentElement === document.body,
      position: window.getComputedStyle(menuElement).position,
      appliedLeft: Number.parseFloat(menuElement.style.left),
      appliedTop: Number.parseFloat(menuElement.style.top),
      expectedLeft: triggerRect.right - menuWidth,
      expectedTop: triggerRect.bottom + 8,
      extendsPastWrapper: Number.parseFloat(menuElement.style.top) > wrapperRect.bottom
    }
  })

  expect(metrics.parentIsBody).toBe(true)
  expect(metrics.position).toBe('fixed')
  expect(Math.abs(metrics.appliedLeft - metrics.expectedLeft)).toBeLessThan(3)
  expect(Math.abs(metrics.appliedTop - metrics.expectedTop)).toBeLessThan(3)
  expect(metrics.extendsPastWrapper).toBe(true)
})