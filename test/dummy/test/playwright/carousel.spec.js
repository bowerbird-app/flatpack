const { test, expect } = require('@playwright/test')

test.describe('carousel drag swipe', () => {
  test('desktop drag swipe moves to next and previous slides', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1800 })
    await page.goto('http://127.0.0.1:3000/demo/carousel', { waitUntil: 'networkidle' })

    const carousel = page.locator('section[data-controller="flat-pack--carousel"]').first()
    const viewport = carousel.locator('[data-flat-pack--carousel-target="viewport"]')
    const counter = carousel.locator('[data-flat-pack--carousel-target="counter"]')

    await expect(counter).toHaveText('1 / 4')

    const box = await viewport.boundingBox()
    if (!box) {
      throw new Error('Carousel viewport is not visible')
    }

    const centerY = box.y + (box.height / 2)
    const startX = box.x + (box.width * 0.8)
    const endX = box.x + (box.width * 0.2)

    await page.mouse.move(startX, centerY)
    await page.mouse.down()
    await page.mouse.move(endX, centerY)
    await page.mouse.up()

    await expect(counter).toHaveText('2 / 4')

    await page.mouse.move(endX, centerY)
    await page.mouse.down()
    await page.mouse.move(startX, centerY)
    await page.mouse.up()

    await expect(counter).toHaveText('1 / 4')
  })
})
