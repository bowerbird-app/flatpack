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
})
