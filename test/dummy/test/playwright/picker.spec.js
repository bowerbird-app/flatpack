const { test, expect } = require("@playwright/test")

test.describe("picker demos", () => {
  test("manual multi-select picker waits for confirm", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const lastPicker = page.locator('[data-picker-demo-target="lastPickerId"]')
    const eventOutput = page.locator('[data-picker-demo-target="eventOutput"]')
    const localModal = page.locator("#picker-demo-local")

    await page.getByRole("button", { name: "Open Local Picker" }).click()
    await expect(localModal).toBeVisible()

    await localModal.locator('input[type="checkbox"]').first().check()
    await expect(lastPicker).toHaveText("none")
    await expect(eventOutput).toContainText("No items selected yet.")

    await localModal.getByRole("button", { name: "Use Selection" }).click()
    await expect(lastPicker).toHaveText("picker-demo-local")
    await expect(eventOutput).not.toContainText("No items selected yet.")
  })

  test("single-select auto-confirm closes modal and syncs field output", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const autoConfirmModal = page.locator("#picker-demo-auto-confirm")
    const lastPicker = page.locator('[data-picker-demo-target="lastPickerId"]')
    const outputField = page.locator("#picker-auto-confirm-field")

    await page.getByRole("button", { name: "Open Auto-Confirm Picker" }).click()
    await expect(autoConfirmModal).toBeVisible()

    await autoConfirmModal.locator('input[type="radio"]').first().check()

    await expect(lastPicker).toHaveText("picker-demo-auto-confirm")
    await expect(outputField).toHaveValue(/"id":"[^"]+"/)
    await expect(autoConfirmModal).toBeHidden()
  })

  test("inline auto-confirm updates field output and stays visible", async ({ page }) => {
    const pageErrors = []
    page.on("pageerror", (error) => pageErrors.push(error.message))

    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const inlinePicker = page.locator("#picker-demo-inline")
    const lastPicker = page.locator('[data-picker-demo-target="lastPickerId"]')
    const outputField = page.locator("#picker-inline-selected-field")

    await expect(inlinePicker).toBeVisible()
    await inlinePicker.locator('input[type="radio"]').first().check()

    await expect(lastPicker).toHaveText("picker-demo-inline")
    await expect(outputField).toHaveValue(/"id":"[^"]+"/)
    await expect(inlinePicker).toBeVisible()
    expect(pageErrors).toEqual([])
  })
})
