import assert from "node:assert/strict"
import test from "node:test"
import {
  composeThemeAttribute,
  readPickerThemeNames,
  readThemeNames,
  themeListIncludes
} from "../../app/javascript/flat_pack/controllers/theme_attribute.js"

const picker = ["system", "light", "dark", "ocean", "rounded", "sunrise"]

test("a single base name still replaces the whole attribute", () => {
  assert.equal(composeThemeAttribute("rounded", "dark", picker), "dark")
  assert.equal(composeThemeAttribute("sunrise", "ocean", picker), "ocean")
  assert.equal(composeThemeAttribute("rounded", "light", picker), null)
  assert.equal(composeThemeAttribute(null, "light", picker), null)
})

test("a custom name survives a base swap and light clears only owned names", () => {
  assert.equal(composeThemeAttribute("rounded harbor", "dark", picker), "dark harbor")
  assert.equal(composeThemeAttribute("rounded harbor", "sunrise", picker), "sunrise harbor")
  assert.equal(composeThemeAttribute("rounded harbor", "light", picker), "harbor")
  assert.equal(composeThemeAttribute("harbor", "dark", picker), "dark harbor")
})

test("dark detection matches the whole name", () => {
  assert.equal(themeListIncludes("dark harbor", "dark"), true)
  assert.equal(themeListIncludes("featured-in-dark", "dark"), false)
  assert.equal(themeListIncludes("rounded", "dark"), false)
  assert.equal(themeListIncludes(null, "dark"), false)
})

test("compose is idempotent", () => {
  const once = composeThemeAttribute("rounded harbor", "ocean", picker)
  assert.equal(composeThemeAttribute(once, "ocean", picker), once)
  assert.equal(composeThemeAttribute(once, "ocean", picker), "ocean harbor")
})

test("readThemeNames splits whitespace and ignores empties", () => {
  assert.deepEqual(readThemeNames("  rounded   harbor "), ["rounded", "harbor"])
  assert.deepEqual(readThemeNames(""), [])
  assert.deepEqual(readThemeNames(null), [])
})

test("readPickerThemeNames reads the switcher list", () => {
  const doc = {
    querySelector() {
      return {
        getAttribute() {
          return JSON.stringify([{ value: "system" }, { value: "sunrise" }, "dark"])
        }
      }
    }
  }

  assert.deepEqual(readPickerThemeNames(doc), ["system", "sunrise", "dark"])
  assert.deepEqual(readPickerThemeNames({ querySelector() { return null } }), [])
})
