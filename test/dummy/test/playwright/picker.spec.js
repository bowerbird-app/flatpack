const { test, expect } = require("@playwright/test")

async function selectPickerRow(container, label) {
  await container.locator("label").filter({ hasText: label }).first().click()
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

  test("field picker hides the file token box and still writes selection", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const fieldModal = page.locator("#picker-demo-field")
    const outputField = page.locator("#picker-selected-assets-field")
    const fileRow = fieldModal.locator("label").filter({ hasText: "Launch Checklist" }).first()

    await page.getByRole("button", { name: "Open Field Picker" }).click()
    await expect(fieldModal).toBeVisible()
    await expect(fileRow.locator("span").filter({ hasText: /^FILE$/ })).toHaveCount(0)

    await selectPickerRow(fieldModal, "Launch Checklist")
    await fieldModal.getByRole("button", { name: "Store Selection" }).click()

    await expect(outputField).toHaveValue(/"label":"Launch Checklist"/)
  })

  test("folder picker hides the record token box and still auto-confirms", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker#records", { waitUntil: "networkidle" })

    const folderModal = page.locator("#picker-demo-folders")
    const outputField = page.locator("#picker-folder-field")
    const folderRow = folderModal.locator("label").filter({ hasText: "Brand Assets" }).first()

    await page.getByRole("button", { name: "Open Folder Picker" }).click()
    await expect(folderModal).toBeVisible()
    await expect(folderRow.locator("span").filter({ hasText: /^FOLDER$/ })).toHaveCount(0)

    await selectPickerRow(folderModal, "Brand Assets")

    await expect(outputField).toHaveValue(/"label":"Brand Assets"/)
    await expect(folderModal).toBeHidden()
  })

  test("built-in form picker submits to a standard Rails controller", async ({ page }) => {
    await page.goto("http://127.0.0.1:3000/demo/picker#built-in-form", { waitUntil: "networkidle" })

    const inlinePicker = page.locator("#picker-demo-built-in-form")
    const resultPanel = page.locator("#picker-demo-built-in-form-result")

    await expect(inlinePicker).toBeVisible()
    await selectPickerRow(inlinePicker, "Brand Assets")
    await inlinePicker.getByRole("button", { name: "Assign Folder" }).click()

    await expect(page).toHaveURL(/\/demo\/picker#built-in-form$/)
    await expect(resultPanel).toContainText("params[:picker_assignment][:folder_record_id]")
    await expect(resultPanel).toContainText("42")
  })

  test("inline auto-confirm updates field output and stays visible", async ({ page }) => {
    const pageErrors = []
    page.on("pageerror", (error) => pageErrors.push(error.message))

    await page.goto("http://127.0.0.1:3000/demo/picker", { waitUntil: "networkidle" })

    const inlinePicker = page.locator("#picker-demo-inline")
    const outputField = page.locator("#picker-inline-selected-field")
    const heroRow = inlinePicker.locator("label").filter({ hasText: "Homepage Hero" }).first()
    const heroInput = heroRow.locator("input[data-item-id]")

    await expect(inlinePicker).toBeVisible()
    await expect(heroInput).toHaveClass(/sr-only/)
    await expect(heroRow).toHaveClass(/hover:bg-\[var\(--list-item-hover-background-color\)\]/)
    await expect(heroRow.locator("[data-picker-selection-indicator]")).toBeVisible()
    await selectPickerRow(inlinePicker, "Homepage Hero")
    await expect(heroRow.locator("[data-picker-selection-indicator]")).toHaveClass(/bg-\(--primary-color\)/)

    await expect(outputField).toHaveValue(/"id":"[^"]+"/)
    await expect(inlinePicker).toBeVisible()
    expect(pageErrors).toEqual([])
  })
})
