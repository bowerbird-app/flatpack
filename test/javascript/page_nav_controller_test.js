const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController(sandbox) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'page_nav_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class PageNavController extends Controller') + '\nmodule.exports = PageNavController\n'

  vm.runInNewContext(transformedSource, sandbox, { filename: filePath })
  return sandbox.module.exports
}

function build({ historyLength = 2, referrer = '', fallbackUrl = '', origin = 'https://studio.test' } = {}) {
  const calls = []
  const event = {
    preventDefault() {
      calls.push('preventDefault')
    }
  }
  const sandbox = {
    module: { exports: {} },
    exports: {},
    URL,
    window: {
      history: {
        length: historyLength,
        back() {
          calls.push('history.back')
        }
      },
      location: {
        origin,
        assign(url) {
          calls.push(['assign', url])
        }
      }
    },
    document: { referrer }
  }
  sandbox.globalThis = sandbox

  const ControllerClass = loadController(sandbox)
  const controller = new ControllerClass()
  controller.fallbackUrlValue = fallbackUrl
  return { controller, event, calls }
}

test('history length of 1 or less assigns the fallback', () => {
  for (const historyLength of [0, 1]) {
    const { controller, event, calls } = build({
      historyLength,
      referrer: '',
      fallbackUrl: '/demo/page_nav'
    })

    controller.back(event)

    assert.deepEqual(calls, ['preventDefault', ['assign', '/demo/page_nav']])
  }
})

test('history length of 1 or less calls history.back when there is no fallback', () => {
  const { controller, event, calls } = build({
    historyLength: 1,
    referrer: 'https://studio.test/demo',
    fallbackUrl: ''
  })

  controller.back(event)

  assert.deepEqual(calls, ['preventDefault', 'history.back'])
})

test('a cross-origin referrer assigns the fallback', () => {
  const { controller, event, calls } = build({
    historyLength: 4,
    referrer: 'https://other.test/start',
    fallbackUrl: '/demo/page_nav'
  })

  controller.back(event)

  assert.deepEqual(calls, ['preventDefault', ['assign', '/demo/page_nav']])
})

test('a cross-origin referrer calls history.back when there is no fallback', () => {
  const { controller, event, calls } = build({
    historyLength: 4,
    referrer: 'https://other.test/start',
    fallbackUrl: ''
  })

  controller.back(event)

  assert.deepEqual(calls, ['preventDefault', 'history.back'])
})

test('an empty referrer with history calls history.back', () => {
  const { controller, event, calls } = build({
    historyLength: 3,
    referrer: '',
    fallbackUrl: '/demo/page_nav'
  })

  controller.back(event)

  assert.deepEqual(calls, ['preventDefault', 'history.back'])
})

test('a same-origin referrer with history calls history.back', () => {
  const { controller, event, calls } = build({
    historyLength: 2,
    referrer: 'https://studio.test/demo/page_nav',
    fallbackUrl: '/demo/page_nav'
  })

  controller.back(event)

  assert.deepEqual(calls, ['preventDefault', 'history.back'])
})

test('a referrer that is not a URL assigns the fallback', () => {
  const { controller, event, calls } = build({
    historyLength: 4,
    referrer: 'not a url',
    fallbackUrl: '/demo/page_nav'
  })

  controller.back(event)

  assert.deepEqual(calls, ['preventDefault', ['assign', '/demo/page_nav']])
})
