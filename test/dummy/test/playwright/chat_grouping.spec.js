const { test, expect } = require('@playwright/test')

test.describe('chat message grouping', () => {
  test('groups consecutive outgoing messages from the same sender', async ({ page }) => {
    await page.goto('http://127.0.0.1:3000/demo/chat/demo', { waitUntil: 'networkidle' })

    const transcript = page.locator('[data-pagination-content]').first()
    const textarea = page.locator('textarea[name="chat[message]"]')

    await textarea.fill('First grouped message')
    await textarea.press('Enter')
    await expect(transcript.locator('[data-flat-pack-chat-record]').last()).toContainText('First grouped message')

    await textarea.fill('Second grouped message')
    await textarea.press('Enter')

    await expect.poll(async () => transcript.locator('[data-flat-pack-chat-record]').count()).toBeGreaterThan(1)

    const firstNewRecord = transcript.locator('[data-flat-pack-chat-record]').filter({ hasText: 'First grouped message' }).last()
    const secondNewRecord = transcript.locator('[data-flat-pack-chat-record]').filter({ hasText: 'Second grouped message' }).last()

    await expect(firstNewRecord).toHaveAttribute('data-flat-pack-chat-grouped-with-previous', 'false')
    await expect(secondNewRecord).toHaveAttribute('data-flat-pack-chat-grouped-with-previous', 'true')
  })
})