const { test, expect } = require('@playwright/test')

test.describe('chat message actions', () => {
  test('sent message reveal opens and dispatches edit events', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/demo/chat/sent_message', { waitUntil: 'networkidle' })

    await page.evaluate(() => {
      window.__chatMessageActionEvents = []

      document.addEventListener('chat-message-actions:edit', (event) => {
        window.__chatMessageActionEvents.push({
          type: event.type,
          expanded: event.detail?.element?.querySelector('[data-flat-pack--chat-message-actions-target="surface"]')?.getAttribute('aria-expanded')
        })
      })
    })

    const message = page.locator('[data-controller="flat-pack--chat-message-actions"]').first()
    const surface = message.locator('[data-flat-pack--chat-message-actions-target="surface"]')
    const tray = message.locator('[data-flat-pack--chat-message-actions-target="tray"]')

    await surface.click()

    await expect(surface).toHaveAttribute('aria-expanded', 'true')
    await expect.poll(async () => surface.evaluate((element) => element.style.transform)).toMatch(/^translateX\(-\d+px\)$/)
    await expect(tray).toHaveClass(/opacity-100/)

    await message.locator('button', { hasText: 'Edit' }).click()

    await expect.poll(() => page.evaluate(() => window.__chatMessageActionEvents.length)).toBe(1)
    await expect(surface).toHaveAttribute('aria-expanded', 'false')
  })
})
