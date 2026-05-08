const { test, expect } = require('@playwright/test')

test.describe('chat sender picker scoping', () => {
  test('ignores picker confirm events from unrelated picker id', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/demo/chat/demo', { waitUntil: 'networkidle' })

    const requests = []
    page.on('request', (request) => {
      if (request.method() !== 'POST') return
      if (!/\/demo\/chat_groups\/\d+\/messages$/.test(request.url())) return
      requests.push(request.url())
    })

    await page.evaluate(() => {
      document.dispatchEvent(new CustomEvent('flat-pack:picker:confirm', {
        bubbles: true,
        detail: {
          pickerId: 'not-chat-picker',
          selection: [
            { kind: 'image', name: 'ignored-image.png', contentType: 'image/png', byteSize: 1200 }
          ]
        }
      }))
    })

    await page.waitForTimeout(400)
    expect(requests.length).toBe(0)
  })

  test('accepts picker confirm events for configured chat picker ids', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/demo/chat/demo', { waitUntil: 'networkidle' })

    const requests = []
    page.on('request', (request) => {
      if (request.method() !== 'POST') return
      if (!/\/demo\/chat_groups\/\d+\/messages$/.test(request.url())) return
      requests.push(request.url())
    })

    await page.evaluate(() => {
      document.dispatchEvent(new CustomEvent('flat-pack:picker:confirm', {
        bubbles: true,
        detail: {
          pickerId: 'chat-picker-images',
          selection: [
            { kind: 'image', name: 'accepted-image.png', contentType: 'image/png', byteSize: 1200 }
          ]
        }
      }))
    })

    await expect.poll(() => requests.length).toBe(1)
  })

  test('renders fallback optimistic messages with chat component structure', async ({ page }) => {
    await page.route(/\/demo\/chat_groups\/\d+\/messages\/preview$/, async (route) => {
      await route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: JSON.stringify({ error: 'preview unavailable' })
      })
    })

    await page.route(/\/demo\/chat_groups\/\d+\/messages$/, async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 300))
      await route.fulfill({
        status: 201,
        contentType: 'application/json',
        body: JSON.stringify({ state: 'sent', timestamp: '10:15 AM' })
      })
    })

    await page.goto('http://127.0.0.1:3000/demo/chat/demo', { waitUntil: 'networkidle' })

    const senderForm = page.locator('form[data-controller*="flat-pack--chat-sender"]').first()
    const textarea = senderForm.locator('textarea[name="chat[message]"]')
    const sendButton = senderForm.getByRole('button', { name: 'Send message' })

    await textarea.fill('Fallback preview message')
    await sendButton.click()

    const optimisticRecord = page.locator('[data-flat-pack-chat-record][data-flat-pack-chat-record-sender="You"]').last()
    await expect(optimisticRecord).toContainText('Fallback preview message')
    await expect(optimisticRecord).toHaveAttribute('data-flat-pack-chat-record-direction', 'outgoing')

    const group = optimisticRecord.locator('[data-flat-pack-chat-group]').first()
    await expect(group).toHaveAttribute('data-flat-pack-chat-group-direction', 'outgoing')

    const bubble = optimisticRecord.locator('[data-flat-pack-chat-sender-bubble]').first()
    await expect(bubble).toHaveClass(/bg-\[var\(--chat-message-outgoing-background-color\)\]/)
    await expect(bubble.locator('div').first()).toHaveClass(/break-words/)

    const meta = optimisticRecord.locator('[data-flat-pack-chat-sender-meta]').first()
    await expect(meta).toContainText('Sending...')
  })
})
