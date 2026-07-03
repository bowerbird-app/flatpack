const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadLocalTime() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'local_time.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source.replaceAll('export function ', 'function ') + `
module.exports = {
  initLocalTimes,
  updateLocalTimeElement,
  formatLocalTime,
  formatRelativeTime,
  formatAbsoluteDate
}
`

  const context = {
    module: { exports: {} },
    exports: {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildElement(options = {}) {
  const {
    className = 'local-time',
    datetime,
    title,
    textContent = 'fallback'
  } = options
  const attributes = {}
  if (Object.hasOwn(options, 'datetime')) {
    if (datetime !== undefined) attributes.datetime = datetime
  } else {
    attributes.datetime = datetime
  }
  if (title !== undefined) attributes.title = title

  return {
    attributes,
    textContent,
    classList: {
      contains(token) {
        return className.split(/\s+/).includes(token)
      }
    },
    getAttribute(name) {
      return this.attributes[name] || null
    },
    hasAttribute(name) {
      return Object.hasOwn(this.attributes, name)
    },
    setAttribute(name, value) {
      this.attributes[name] = value
    }
  }
}

test('formatRelativeTime renders Just now for less than 60 seconds', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-07-03T11:59:30Z'), now), 'Just now')
})

test('formatRelativeTime renders minutes ago', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-07-03T11:48:00Z'), now), '12 minutes ago')
})

test('formatRelativeTime renders hours ago', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-07-03T07:00:00Z'), now), '5 hours ago')
})

test('formatRelativeTime renders Yesterday for 24 to 47 hours ago', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-07-02T11:00:00Z'), now), 'Yesterday')
})

test('formatRelativeTime renders days ago', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-06-30T12:00:00Z'), now), '3 days ago')
})

test('formatRelativeTime renders weeks ago rounded down', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-06-18T12:00:00Z'), now), '2 weeks ago')
})

test('formatRelativeTime renders months ago rounded down', () => {
  const { formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')

  assert.equal(formatRelativeTime(new Date('2026-03-05T12:00:00Z'), now), '4 months ago')
})

test('formatRelativeTime renders an absolute date after a year', () => {
  const { formatAbsoluteDate, formatRelativeTime } = loadLocalTime()
  const now = new Date('2026-07-03T12:00:00Z')
  const date = new Date('2025-05-29T12:00:00Z')

  assert.equal(formatRelativeTime(date, now), formatAbsoluteDate(date))
})

test('updateLocalTimeElement replaces valid local time text and adds title', () => {
  const { formatLocalTime, updateLocalTimeElement } = loadLocalTime()
  const datetime = '2026-07-03T14:30:00Z'
  const element = buildElement({ datetime })

  updateLocalTimeElement(element, new Date('2026-07-03T15:00:00Z'))

  assert.equal(element.textContent, formatLocalTime(new Date(datetime)))
  assert.equal(element.attributes.title, datetime)
  assert.equal(element.attributes.datetime, datetime)
})

test('updateLocalTimeElement preserves existing title', () => {
  const { updateLocalTimeElement } = loadLocalTime()
  const element = buildElement({ title: 'Custom title' })

  updateLocalTimeElement(element)

  assert.equal(element.attributes.title, 'Custom title')
})

test('updateLocalTimeElement renders relative time for relative-time elements', () => {
  const { updateLocalTimeElement } = loadLocalTime()
  const element = buildElement({
    className: 'local-time relative-time',
    datetime: '2026-07-03T11:48:00Z'
  })

  updateLocalTimeElement(element, new Date('2026-07-03T12:00:00Z'))

  assert.equal(element.textContent, '12 minutes ago')
})

test('updateLocalTimeElement leaves invalid datetime unchanged', () => {
  const { updateLocalTimeElement } = loadLocalTime()
  const element = buildElement({ datetime: 'not-a-valid-date' })

  updateLocalTimeElement(element)

  assert.equal(element.textContent, 'fallback')
  assert.equal(element.attributes.title, undefined)
  assert.equal(element.attributes.datetime, 'not-a-valid-date')
})

test('updateLocalTimeElement leaves missing datetime unchanged', () => {
  const { updateLocalTimeElement } = loadLocalTime()
  const element = buildElement({ datetime: undefined })

  updateLocalTimeElement(element)

  assert.equal(element.textContent, 'fallback')
  assert.equal(element.attributes.title, undefined)
})

test('initLocalTimes updates each matching element under the root', () => {
  const { initLocalTimes } = loadLocalTime()
  const elements = [
    buildElement({ className: 'local-time relative-time', datetime: '2026-07-03T11:48:00Z' }),
    buildElement({ className: 'local-time', datetime: '2026-07-03T14:30:00Z' })
  ]
  const root = {
    selector: null,
    querySelectorAll(selector) {
      this.selector = selector
      return elements
    }
  }

  initLocalTimes(root, new Date('2026-07-03T12:00:00Z'))

  assert.equal(root.selector, 'time.local-time')
  assert.equal(elements[0].textContent, '12 minutes ago')
  assert.notEqual(elements[1].textContent, 'fallback')
})
