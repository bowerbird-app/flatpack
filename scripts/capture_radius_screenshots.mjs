import { createRequire } from "node:module"
import { mkdir } from "node:fs/promises"
import path from "node:path"

const require = createRequire(new URL("../test/dummy/package.json", import.meta.url))
const { chromium } = require("playwright")

const origin = process.env.FLATPACK_ORIGIN ?? "http://127.0.0.1:3000"
const outDir = process.argv[2]
if (!outDir) {
  console.error("usage: node scripts/capture_radius_screenshots.mjs <out-dir>")
  process.exit(1)
}

const pages = [
  ["/demo/buttons", "buttons"],
  ["/demo/forms/text_input", "forms-text-input"],
  ["/demo/cards", "cards"],
  ["/demo/modals", "modals"],
  ["/demo/sidebar/complete", "sidebar"],
  ["/demo/chat/panel", "chat-panel"],
  ["/demo/comments", "comments"],
  ["/demo/tabs", "tabs"],
  ["/demo/buttons/dropdowns", "dropdowns"]
]

const themes = ["light", "dark", "ocean"]

const browser = await chromium.launch({ args: ["--no-sandbox"] })
await mkdir(outDir, { recursive: true })

for (const theme of themes) {
  for (const [route, slug] of pages) {
    const context = await browser.newContext({
      viewport: { width: 1440, height: 900 },
      colorScheme: "light"
    })
    await context.addInitScript((nextTheme) => {
      localStorage.setItem("flatpack-theme", nextTheme)
      localStorage.setItem("flatpack-dummy-theme", nextTheme)
    }, theme)
    const page = await context.newPage()
    const response = await page.goto(`${origin}${route}`, { waitUntil: "networkidle" })
    if (!response || !response.ok()) {
      throw new Error(`${route} returned ${response?.status()}`)
    }
    await page.waitForTimeout(400)
    const dest = path.join(outDir, `${slug}-${theme}.png`)
    await page.screenshot({ path: dest, fullPage: false })
    console.log(dest)
    await context.close()
  }
}

await browser.close()
