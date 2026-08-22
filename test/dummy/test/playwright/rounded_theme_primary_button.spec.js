const { test, expect } = require('@playwright/test')

function isCharcoalPrimary(value) {
  const normalized = String(value || '').trim().toLowerCase()

  if (normalized.includes('0.3211') && normalized.includes('oklch')) return true
  if (['#1f1f1f', '#333', '#333333', 'rgb(31, 31, 31)', 'rgb(51, 51, 51)'].includes(normalized)) return true

  const rgb = normalized.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/)
  if (rgb) {
    const [red, green, blue] = rgb.slice(1, 4).map(Number)
    const max = Math.max(red, green, blue)
    const min = Math.min(red, green, blue)
    return max <= 60 && (max - min) <= 8
  }

  const oklch = normalized.match(/oklch\(\s*([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)/)
  if (oklch) {
    const lightness = Number(oklch[1])
    const chroma = Number(oklch[2])
    const hue = Number(oklch[3])
    return lightness >= 0.20 && lightness <= 0.40 && chroma <= 0.03 && (chroma < 0.01 || hue === 0)
  }

  return false
}

async function assertPrimaryButtonIsCharcoal(page, button, label) {
  const background = await button.evaluate((element) => getComputedStyle(element).backgroundColor)
  const token = await page.evaluate(() =>
    getComputedStyle(document.body).getPropertyValue('--button-primary-background-color').trim()
  )

  expect(background, `${label} computed background`).not.toMatch(/250/)
  expect(token, `${label} --button-primary-background-color`).not.toMatch(/250/)
  expect(isCharcoalPrimary(background), `${label} background should be charcoal, got ${background}`).toBeTruthy()
  expect(isCharcoalPrimary(token), `${label} token should be charcoal, got ${token}`).toBeTruthy()
}

test('rounded theme preview primary button is charcoal, not default hue 250', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/themes/previews/rounded', { waitUntil: 'networkidle' })

  await expect(page.locator('html')).toHaveAttribute('data-theme', 'rounded')
  await expect(page.locator('body')).toHaveAttribute('data-theme', 'rounded')

  const button = page.locator('[data-flat-pack-preview="theme-primary-button"]')
  await expect(button).toBeVisible()
  await assertPrimaryButtonIsCharcoal(page, button, 'html+body data-theme=rounded')

  await page.evaluate(() => {
    document.documentElement.removeAttribute('data-theme')
    document.body.setAttribute('data-theme', 'rounded')
  })

  await assertPrimaryButtonIsCharcoal(page, button, 'body-only data-theme=rounded')
})

function isRoundedMdRadius(value) {
  const normalized = String(value || '').trim().toLowerCase()
  if (normalized === '1rem' || normalized === '16px') return true
  const pixels = normalized.match(/^(\d+(?:\.\d+)?)px$/)
  if (pixels) {
    const size = Number(pixels[1])
    return size >= 15 && size <= 17
  }
  return false
}

test('rounded theme PageNav back uses 1rem radius, not :root 6px', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/themes/previews/rounded', { waitUntil: 'networkidle' })

  await page.evaluate(() => {
    document.documentElement.removeAttribute('data-theme')
    document.body.setAttribute('data-theme', 'rounded')
  })

  const back = page.locator('[data-flat-pack-preview="theme-page-nav"] [data-action="click->flat-pack--page-nav#back"]')
  await expect(back).toBeVisible()

  const measured = await back.evaluate((element) => {
    const style = getComputedStyle(element)
    return {
      width: style.width,
      height: style.height,
      radius: style.borderRadius,
      token: getComputedStyle(document.body).getPropertyValue('--button-border-radius').trim(),
      radiusMd: getComputedStyle(document.body).getPropertyValue('--radius-md').trim()
    }
  })

  expect(measured.radiusMd).toBe('1rem')
  expect(measured.token).toBe('1rem')
  expect(measured.radius).not.toBe('6px')
  expect(measured.radius).not.toBe('0.375rem')
  expect(isRoundedMdRadius(measured.radius), `PageNav back radius should be 1rem, got ${JSON.stringify(measured)}`).toBeTruthy()
})
