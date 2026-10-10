const { test, expect } = require("@playwright/test")

const DEMO_SURFACES = [
  "#title [role='textbox']",
  "#page-title [role='textbox']",
  "#hero [role='textbox']",
  "#plain [role='textbox']",
  "#rich [role='textbox']",
  "#form-only [role='textbox']",
  "#error [role='textbox']",
  "#dark [role='textbox']",
  "#placeholder [role='textbox']"
]

async function boxOf(locator) {
  const box = await locator.boundingBox()
  return { width: box.width, height: box.height, x: box.x, y: box.y }
}

function assertNoShift(rest, next, label) {
  expect(Math.abs(rest.width - next.width), `${label} width`).toBeLessThan(1)
  expect(Math.abs(rest.height - next.height), `${label} height`).toBeLessThan(1)
  expect(Math.abs(rest.x - next.x), `${label} x`).toBeLessThan(1)
  expect(Math.abs(rest.y - next.y), `${label} y`).toBeLessThan(1)
}

test("title click type enter save and escape cancel", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 1200 })
  await page.goto("http://127.0.0.1:3000/demo/inline_edit", { waitUntil: "networkidle" })

  const title = page.locator("#title [role='textbox']").first()
  await expect(title).toHaveText("Summer field kit")

  const rest = await boxOf(title)
  await title.hover()
  assertNoShift(rest, await boxOf(title), "title hover")

  await title.click()
  assertNoShift(rest, await boxOf(title), "title editing")

  await page.keyboard.press("End")
  await page.keyboard.type(" plus")
  await page.keyboard.press("Enter")
  await expect(page.locator("#inline-edit-saved-copy")).toContainText("Summer field kit plus")

  await title.click()
  await page.keyboard.type(" no")
  await page.keyboard.press("Escape")
  await expect(title).toHaveText("Summer field kit plus")
})

test("rest hover editing boxes match on every demo", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 1600 })
  await page.goto("http://127.0.0.1:3000/demo/inline_edit", { waitUntil: "networkidle" })

  for (const selector of DEMO_SURFACES) {
    const surface = page.locator(selector).first()
    await surface.scrollIntoViewIfNeeded()
    const rest = await boxOf(surface)
    await surface.hover()
    assertNoShift(rest, await boxOf(surface), `${selector} hover`)
    await surface.click()
    assertNoShift(rest, await boxOf(surface), `${selector} editing`)
    await page.keyboard.press("Escape")
  }
})

function paintOf(locator) {
  return locator.evaluate((el) => {
    const style = getComputedStyle(el)
    return { backgroundColor: style.backgroundColor, boxShadow: style.boxShadow }
  })
}

function isTransparent(color) {
  const normalized = color.replace(/\s+/g, " ").trim()
  if (/^(transparent|rgba?\(0, 0, 0, 0\))$/i.test(normalized)) return true
  return /\/\s*0(?:\.0+)?\s*\)$/.test(normalized)
}

test("default cue is highlight and cursor is text", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 900 })
  await page.goto("http://127.0.0.1:3000/demo/inline_edit", { waitUntil: "networkidle" })

  const title = page.locator("#title .fp-inline-edit").first()
  await expect(title).toHaveClass(/fp-inline-edit--cue-highlight/)

  const surface = page.locator("#title [role='textbox']").first()
  await expect(surface).toHaveCSS("cursor", "text")

  const reduced = await page.evaluate(() => {
    const el = document.querySelector("#title .fp-inline-edit__surface")
    const style = getComputedStyle(el)
    return { transition: style.transition }
  })
  expect(reduced.transition).not.toEqual("all 0s ease 0s")
})

test("hover washes, editing is caret only, tab shows wash", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 900 })
  await page.goto("http://127.0.0.1:3000/demo/inline_edit", { waitUntil: "networkidle" })

  const surface = page.locator("#title [role='textbox']").first()
  const rest = await paintOf(surface)
  expect(isTransparent(rest.backgroundColor)).toBeTruthy()

  await surface.hover()
  await page.waitForTimeout(200)
  const hover = await paintOf(surface)
  expect(isTransparent(hover.backgroundColor)).toBeFalsy()

  await surface.click()
  await surface.hover()
  await page.waitForTimeout(200)
  const editing = await paintOf(surface)
  expect(isTransparent(editing.backgroundColor)).toBeTruthy()
  await page.keyboard.press("Escape")

  await page.mouse.click(8, 8)
  await surface.evaluate((el) => el.focus({ focusVisible: true }))
  await page.waitForTimeout(200)
  const keyed = await paintOf(surface)
  expect(isTransparent(keyed.backgroundColor)).toBeFalsy()
})
