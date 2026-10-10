const { test, expect } = require("@playwright/test")

test("title click type enter save and escape cancel", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 1200 })
  await page.goto("http://127.0.0.1:3000/demo/inline_edit", { waitUntil: "networkidle" })

  const title = page.locator("#title [role='textbox']").first()
  await expect(title).toHaveText("Summer field kit")

  const before = await title.boundingBox()
  await title.click()
  const after = await title.boundingBox()
  expect(Math.abs(before.width - after.width)).toBeLessThan(2)
  expect(Math.abs(before.height - after.height)).toBeLessThan(2)

  await page.keyboard.type(" plus")
  await page.keyboard.press("Enter")
  await expect(page.locator("#inline-edit-saved-copy")).toContainText("Summer field kit plus")

  await title.click()
  await page.keyboard.type(" no")
  await page.keyboard.press("Escape")
  await expect(title).toHaveText("Summer field kit plus")
})
