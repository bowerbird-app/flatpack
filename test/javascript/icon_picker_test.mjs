import assert from "node:assert/strict"
import test from "node:test"
import { iconMatches, moveIndex, normalizeIconQuery } from "../../app/javascript/flat_pack/icon_picker.js"

test("search treats hyphens, spaces, and case as the same", () => {
  assert.equal(normalizeIconQuery("Arrow Right"), "arrowright")
  assert.equal(iconMatches("arrow-right", "arrow"), true)
  assert.equal(iconMatches("arrow-right", "Arrow Right"), true)
  assert.equal(iconMatches("arrow-right", "star"), false)
  assert.equal(iconMatches("arrow-right", ""), true)
  assert.equal(iconMatches("arrow-right", "   "), true)
})

test("arrow keys move by column and stop at the edges", () => {
  assert.equal(moveIndex(0, 10, 4, "ArrowRight"), 1)
  assert.equal(moveIndex(0, 10, 4, "ArrowLeft"), 0)
  assert.equal(moveIndex(1, 10, 4, "ArrowDown"), 5)
  assert.equal(moveIndex(5, 10, 4, "ArrowUp"), 1)
  assert.equal(moveIndex(9, 10, 4, "ArrowDown"), 9)
  assert.equal(moveIndex(2, 10, 4, "Home"), 0)
  assert.equal(moveIndex(2, 10, 4, "End"), 9)
  assert.equal(moveIndex(3, 10, 4, "Enter"), 3)
  assert.equal(moveIndex(0, 0, 4, "ArrowRight"), 0)
})
