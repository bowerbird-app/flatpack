const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')

test('picker checkbox classes use theme primary CSS vars', () => {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'picker_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')

  assert.match(source, /accent-\[var\(--color-primary\)\]/)
  assert.match(source, /checked:bg-\[var\(--color-primary\)\]/)
  assert.match(source, /checked:border-\[var\(--color-primary\)\]/)
  assert.match(source, /checked:text-\[var\(--color-primary-text\)\]/)
  assert.doesNotMatch(source, /"accent-primary"/)
  assert.doesNotMatch(source, /checked:bg-primary(?![-\[])/)
  assert.doesNotMatch(source, /checked:border-primary(?![-\[])/)
  assert.doesNotMatch(source, /"text-primary"/)
})
