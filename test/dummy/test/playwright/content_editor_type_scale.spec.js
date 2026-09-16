const { test, expect } = require('@playwright/test')

async function articleSizes(page, root) {
  return page.evaluate((selector) => {
    const content = document.querySelector(selector)
    const paragraph = content.querySelector('p')
    const h2 = content.querySelector('h2')
    const h3 = content.querySelector('h3')
    const htmlSize = getComputedStyle(document.documentElement).fontSize
    return {
      htmlSize,
      contentSize: getComputedStyle(content).fontSize,
      paragraphSize: getComputedStyle(paragraph).fontSize,
      h2Size: getComputedStyle(h2).fontSize,
      h3Size: getComputedStyle(h3).fontSize
    }
  }, root)
}

test('content editor type scale at a 16px root', async ({ page }) => {
  await page.addInitScript(() => {
    document.documentElement.style.fontSize = '16px'
  })
  await page.setViewportSize({ width: 1440, height: 1200 })
  await page.goto('http://127.0.0.1:3000/demo/content-editor', { waitUntil: 'networkidle' })

  const display = await articleSizes(page, '[data-flat-pack--content-editor-target="displayContent"]')
  expect(display.htmlSize).toBe('16px')
  expect(display.contentSize).toBe('18px')
  expect(display.paragraphSize).toBe('18px')
  expect(display.h2Size).toBe('27px')
  expect(display.h3Size).toBe('22.5px')

  const published = await articleSizes(page, '[data-published-article]')
  expect(published.paragraphSize).toBe('18px')
  expect(published.h2Size).toBe('27px')

  await page.getByRole('button', { name: 'Edit' }).click()
  const editing = await articleSizes(page, '[data-flat-pack--content-editor-target="displayContent"]')
  expect(editing.paragraphSize).toBe('18px')
  expect(editing.h2Size).toBe('27px')
  expect(editing.h3Size).toBe('22.5px')
})
