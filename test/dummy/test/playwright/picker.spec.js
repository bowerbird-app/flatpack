const { test, expect } = require("@playwright/test")

async function selectPickerRow(container, label) {
  await container.locator("label").filter({ hasText: label }).first().locator("input[data-item-id]").setChecked(true, { force: true })
}

test.describe("picker demos", () => {
  test("manual multi-select picker waits for confirm", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const lastPicker = page.locator("#picker-demo-local-last-picker")
    const eventOutput = page.locator("#picker-demo-local-event-output")
    const localModal = page.locator("#picker-demo-local")
    const heroRow = localModal.locator("label").filter({ hasText: "Homepage Hero" }).first()

    await page.getByRole("button", { name: "Open Local Picker" }).click()
    await expect(localModal).toBeVisible()

    await selectPickerRow(localModal, "Homepage Hero")
    await expect(heroRow.locator("[data-picker-selection-indicator]")).toHaveClass(/bg-\(--primary-color\)/)

    await localModal.getByRole("button", { name: "Use Selection" }).click()
    await expect(lastPicker).toHaveText("picker-demo-local")
    await expect(eventOutput).not.toContainText("No items selected yet.")
  })

  test("remote picker updates its own event output panel", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const lastPicker = page.locator("#picker-demo-remote-last-picker")
    const eventOutput = page.locator("#picker-demo-remote-event-output")
    const remoteModal = page.locator("#picker-demo-remote")

    await page.getByRole("button", { name: "Open Remote Picker" }).click()
    await expect(remoteModal).toBeVisible()

    await selectPickerRow(remoteModal, "Homepage Hero")

    await remoteModal.getByRole("button", { name: "Use Remote Selection" }).click()
    await expect(lastPicker).toHaveText("picker-demo-remote")
    await expect(eventOutput).not.toContainText("No items selected yet.")
  })

  test("single-select auto-confirm closes modal and syncs field output", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const autoConfirmModal = page.locator("#picker-demo-auto-confirm")
    const outputField = page.locator("#picker-auto-confirm-field")
    const heroRow = autoConfirmModal.locator("label").filter({ hasText: "Homepage Hero" }).first()

    await page.getByRole("button", { name: "Open Auto-Confirm Picker" }).click()
    await expect(autoConfirmModal).toBeVisible()

    await selectPickerRow(autoConfirmModal, "Homepage Hero")
    await expect(heroRow.locator("[data-picker-selection-indicator]")).toHaveClass(/bg-\(--primary-color\)/)

    await expect(outputField).toHaveValue(/"id":"[^"]+"/)
    await expect(autoConfirmModal).toBeHidden()
  })

  test("inline auto-confirm updates field output and stays visible", async ({ page }) => {
    const pageErrors = []
    page.on("pageerror", (error) => pageErrors.push(error.message))

    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const inlinePicker = page.locator("#picker-demo-inline")
    const outputField = page.locator("#picker-inline-selected-field")
    const heroRow = inlinePicker.locator("label").filter({ hasText: "Homepage Hero" }).first()

    await expect(inlinePicker).toBeVisible()
    await selectPickerRow(inlinePicker, "Homepage Hero")
    await expect(heroRow.locator("[data-picker-selection-indicator]")).toHaveClass(/bg-\(--primary-color\)/)

    await expect(outputField).toHaveValue(/"id":"[^"]+"/)
    await expect(inlinePicker).toBeVisible()
    expect(pageErrors).toEqual([])
  })
})
