const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'test', 'dummy', 'app', 'javascript', 'controllers', 'pill_buttons_demo_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class PillButtonsDemoController extends Controller') + '\nmodule.exports = PillButtonsDemoController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    URL,
    decodeURIComponent,
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildPill(href, classNames = []) {
  const classes = new Set(classNames)
  const attributes = {}

  return {
    href,
    classList: {
      add(...tokens) {
        tokens.forEach((token) => classes.add(token))
      },
      remove(...tokens) {
        tokens.forEach((token) => classes.delete(token))
      },
      contains(token) {
        return classes.has(token)
      }
    },
    setAttribute(name, value) {
      attributes[name] = value
    },
    removeAttribute(name) {
      delete attributes[name]
    },
    getAttribute(name) {
      return attributes[name]
    }
  }
}

test('same-page pill clicks prevent navigation reload and update hash state manually', () => {
  const scrollCalls = []
  const pushStateCalls = []
  const accountTarget = {
    scrollIntoView(options) {
      scrollCalls.push(options)
    }
  }

  const document = {
    getElementById(id) {
      return id === 'pill-anchor-account' ? accountTarget : null
    }
  }

  const windowObject = {
    location: {
      href: 'http://example.test/demo/buttons',
      pathname: '/demo/buttons',
      search: '',
      hash: ''
    },
    history: {
      pushState(_state, _title, hash) {
        pushStateCalls.push(hash)
        windowObject.location.hash = hash
      }
    }
  }

  const PillButtonsDemoController = loadController({ document, window: windowObject })
  const controller = new PillButtonsDemoController()
  const accountPill = buildPill('http://example.test/demo/buttons#pill-anchor-account', ['inactive'])
  const billingPill = buildPill('http://example.test/demo/buttons#pill-anchor-billing', ['active'])

  controller.pillTargets = [accountPill, billingPill]
  controller.activeClassesValue = 'active'
  controller.inactiveClassesValue = 'inactive'

  let prevented = false
  controller.activate({
    currentTarget: accountPill,
    preventDefault() {
      prevented = true
    }
  })

  assert.equal(prevented, true)
  assert.deepEqual(pushStateCalls, ['#pill-anchor-account'])
  assert.equal(scrollCalls.length, 1)
  assert.equal(scrollCalls[0].block, 'start')
  assert.equal(scrollCalls[0].behavior, 'smooth')
  assert.equal(accountPill.classList.contains('active'), true)
  assert.equal(accountPill.classList.contains('inactive'), false)
  assert.equal(accountPill.getAttribute('aria-current'), 'page')
  assert.equal(billingPill.classList.contains('active'), false)
  assert.equal(billingPill.classList.contains('inactive'), true)
  assert.equal(billingPill.getAttribute('aria-current'), undefined)
})