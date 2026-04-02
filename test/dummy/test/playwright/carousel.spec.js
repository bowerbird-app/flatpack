const { test, expect } = require('@playwright/test')

test.describe('carousel drag swipe', () => {
  test('chevron controls move between slides when clicked', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1800 })
    await page.goto('http://127.0.0.1:3000/demo/carousel', { waitUntil: 'networkidle' })

    const carousel = page.locator('section[data-controller="flat-pack--carousel"]').first()
    const counter = carousel.locator('[data-flat-pack--carousel-target="counter"]')
    const prevButton = carousel.locator('button[data-action="click->flat-pack--carousel#prev"]')
    const nextButton = carousel.locator('button[data-action="click->flat-pack--carousel#next"]')

    await expect(counter).toHaveText('1 / 4')

    await nextButton.click()
    await expect(counter).toHaveText('2 / 4')

    await prevButton.click()
    await expect(counter).toHaveText('1 / 4')
  })

  test('desktop drag swipe moves to next and previous slides', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1800 })
    await page.goto('http://127.0.0.1:3000/demo/carousel', { waitUntil: 'networkidle' })

    const carousel = page.locator('section[data-controller="flat-pack--carousel"]').first()
    const viewport = carousel.locator('[data-flat-pack--carousel-target="viewport"]')
    const counter = carousel.locator('[data-flat-pack--carousel-target="counter"]')

    await expect(counter).toHaveText('1 / 4')
    await viewport.scrollIntoViewIfNeeded()

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

  test('image lightbox opens and closes from expand control', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1800 })
    await page.goto('http://127.0.0.1:3000/demo/carousel', { waitUntil: 'networkidle' })

    const carousel = page.locator('section[data-controller="flat-pack--carousel"]').first()
    const expandButton = carousel.locator('button[data-flat-pack--carousel-target="lightboxToggle"]')
    const lightbox = carousel.locator('[data-flat-pack--carousel-target="lightbox"]')
    const lightboxImage = carousel.locator('[data-flat-pack--carousel-target="lightboxImage"]')

    await expect(expandButton).toBeVisible()
    await expect(lightbox).toBeHidden()

    await expandButton.click()

    await expect(lightbox).toBeVisible()
    await expect(lightboxImage).toHaveAttribute('src', /photo-1460925895917-afdab827c52f/)

    await page.keyboard.press('Escape')
    await expect(lightbox).toBeHidden()
  })
})
