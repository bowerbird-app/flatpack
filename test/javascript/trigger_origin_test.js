const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadTriggerOrigin(options = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'trigger_origin.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace(
      'import { prefersReducedMotion, motionTransition } from "controllers/flat_pack/reduced_motion"',
      `
        function prefersReducedMotion() { return Boolean(globalThis.__reducedMotion) }
        function motionTransition(properties, { duration, easing } = {}) {
          const list = Array.isArray(properties) ? properties : [properties]
          return list.map((property) => property + ' var(--duration-' + duration + ') var(--easing-' + easing + ')').join(', ')
        }
      `
    )
    .replaceAll('export function ', 'function ')
    .replaceAll('export const ', 'const ') + `
module.exports = {
  TRIGGER_ORIGIN,
  CENTER_ORIGIN,
  MIN_VIEWPORT_WIDTH,
  isTriggerOrigin,
  resolveTrigger,
  isUsableTrigger,
  triggerIsOnScreen,
  viewportAllowsTriggerOrigin,
  canUseTriggerOrigin,
  computeTriggerOriginMotion,
  applyTriggerOriginStart,
  playTriggerOriginEnter,
  playTriggerOriginExit,
  clearTriggerOriginStyles
}
`

  const context = {
    module: { exports: {} },
    exports: {},
    document: options.document || {
      body: { nodeType: 1 },
      documentElement: { nodeType: 1 }
    },
    globalThis: {
      innerWidth: options.innerWidth ?? 1024,
      innerHeight: options.innerHeight ?? 768,
      __reducedMotion: Boolean(options.reducedMotion)
    }
  }
  context.globalThis.matchMedia = () => ({ matches: Boolean(options.reducedMotion) })

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function element(rect, extras = {}) {
  return {
    nodeType: 1,
    isConnected: extras.isConnected ?? true,
    closest: extras.closest || (() => extras.closestResult || null),
    getBoundingClientRect: () => rect,
    style: extras.style || {},
    offsetHeight: 1,
    ...extras.rest
  }
}

test('isTriggerOrigin is only true for trigger', () => {
  const { isTriggerOrigin } = loadTriggerOrigin()

  assert.equal(isTriggerOrigin('trigger'), true)
  assert.equal(isTriggerOrigin('center'), false)
  assert.equal(isTriggerOrigin(''), false)
  assert.equal(isTriggerOrigin(undefined), false)
})

test('resolveTrigger prefers the stored control then the closest modal trigger', () => {
  const { resolveTrigger } = loadTriggerOrigin()
  const closest = element({ left: 0, top: 0, width: 40, height: 20, right: 40, bottom: 20 })
  const stored = element({ left: 10, top: 10, width: 20, height: 10, right: 30, bottom: 20 }, {
    closest: (selector) => selector === '[data-modal-id]' ? closest : null
  })

  assert.equal(resolveTrigger(stored, null), closest)
  assert.equal(resolveTrigger(null, stored), closest)
})

test('resolveTrigger ignores body, disconnected nodes, and controls inside a dialog', () => {
  const { resolveTrigger, isUsableTrigger } = loadTriggerOrigin()
  const root = { body: { nodeType: 1 }, documentElement: { nodeType: 1 } }
  const body = root.body
  body.getBoundingClientRect = () => ({ left: 0, top: 0, width: 100, height: 100, right: 100, bottom: 100 })

  assert.equal(isUsableTrigger(body, root), false)
  assert.equal(isUsableTrigger(element({ width: 10, height: 10 }, { isConnected: false }), root), false)
  assert.equal(
    isUsableTrigger(element({ width: 10, height: 10 }, { closest: (selector) => selector === '[role="dialog"]' ? {} : null }), root),
    false
  )
  assert.equal(resolveTrigger(null, body, root), null)
})

test('computeTriggerOriginMotion scales from the trigger and sits the card on it', () => {
  const { computeTriggerOriginMotion } = loadTriggerOrigin()
  const panelRect = { left: 200, top: 100, width: 400, height: 300, right: 600, bottom: 400 }
  const triggerRect = { left: 20, top: 20, width: 80, height: 40, right: 100, bottom: 60 }

  const motion = computeTriggerOriginMotion(panelRect, triggerRect)

  assert.equal(motion.transformOrigin, '-140px -60px')
  assert.equal(motion.transform, 'translate(-45.33px, -28px) scale(0.1333)')
})

test('canUseTriggerOrigin falls back when motion is reduced, the viewport is narrow, or the trigger is off-screen', () => {
  const helper = loadTriggerOrigin({ innerWidth: 390, reducedMotion: false })
  const trigger = element({ left: 10, top: 10, width: 40, height: 20, right: 50, bottom: 30 })
  const panel = element({ left: 40, top: 40, width: 400, height: 300, right: 440, bottom: 340 })

  assert.equal(helper.viewportAllowsTriggerOrigin({ innerWidth: 390 }), false)
  assert.equal(helper.canUseTriggerOrigin(trigger, panel, { viewport: { innerWidth: 390, innerHeight: 844 } }), false)
  assert.equal(helper.canUseTriggerOrigin(trigger, panel, { viewport: { innerWidth: 1024, innerHeight: 768 }, reducedMotion: true }), false)
  assert.equal(helper.triggerIsOnScreen({ left: -80, top: -40, width: 40, height: 20, right: -40, bottom: -20 }, { innerWidth: 1024, innerHeight: 768 }), false)
  assert.equal(helper.canUseTriggerOrigin(trigger, panel, { viewport: { innerWidth: 1024, innerHeight: 768 }, reducedMotion: false }), true)
})

test('applyTriggerOriginStart writes transform and leaves scale at none', () => {
  const { applyTriggerOriginStart } = loadTriggerOrigin()
  const trigger = element({ left: 20, top: 20, width: 80, height: 40, right: 100, bottom: 60 })
  const panel = element({ left: 200, top: 100, width: 400, height: 300, right: 600, bottom: 400 }, { style: {} })

  const motion = applyTriggerOriginStart(panel, trigger)

  assert.equal(panel.style.scale, 'none')
  assert.equal(panel.style.opacity, '0')
  assert.equal(panel.style.transformOrigin, motion.transformOrigin)
  assert.equal(panel.style.transform, motion.transform)
})

test('playTriggerOriginEnter uses duration-slow and identity transform', () => {
  const { playTriggerOriginEnter } = loadTriggerOrigin()
  const panel = element({ left: 0, top: 0, width: 100, height: 100, right: 100, bottom: 100 }, { style: { transform: 'scale(0.2)', opacity: '0' } })

  playTriggerOriginEnter(panel)

  assert.equal(panel.style.opacity, '1')
  assert.equal(panel.style.transform, 'none')
  assert.match(panel.style.transition, /opacity var\(--duration-slow\) var\(--easing-enter\)/)
  assert.match(panel.style.transition, /transform var\(--duration-slow\) var\(--easing-enter\)/)
})

test('playTriggerOriginExit remeasures and returns false when the trigger is gone', () => {
  const { playTriggerOriginExit } = loadTriggerOrigin()
  const panel = element({ left: 200, top: 100, width: 400, height: 300, right: 600, bottom: 400 }, { style: {} })
  const trigger = element({ left: 20, top: 20, width: 80, height: 40, right: 100, bottom: 60 })

  assert.equal(playTriggerOriginExit(panel, trigger, { viewport: { innerWidth: 1024, innerHeight: 768 } }), true)
  assert.equal(panel.style.opacity, '0')
  assert.match(panel.style.transform, /scale\(/)
  assert.match(panel.style.transition, /--duration-base/)
  assert.match(panel.style.transition, /--easing-exit/)

  const missing = element({ left: 0, top: 0, width: 0, height: 0, right: 0, bottom: 0 }, { isConnected: false })
  assert.equal(playTriggerOriginExit(panel, missing, { viewport: { innerWidth: 1024, innerHeight: 768 } }), false)
})

test('clearTriggerOriginStyles removes only the motion inline styles', () => {
  const { clearTriggerOriginStyles } = loadTriggerOrigin()
  const panel = {
    style: {
      transform: 'scale(0.2)',
      transformOrigin: '10px 10px',
      transition: 'transform 200ms',
      opacity: '0',
      scale: 'none',
      color: 'red',
      removeProperty(name) {
        const key = name.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
        delete this[key]
      }
    }
  }

  clearTriggerOriginStyles(panel)

  assert.equal(panel.style.transform, undefined)
  assert.equal(panel.style.opacity, undefined)
  assert.equal(panel.style.scale, undefined)
  assert.equal(panel.style.color, 'red')
})
