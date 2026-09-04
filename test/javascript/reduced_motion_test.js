const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadReducedMotion(matchMedia) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'reduced_motion.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source.replaceAll('export function ', 'function ') + `
module.exports = { prefersReducedMotion, motionDuration, motionTransition, overlayOrigin, overlayEnterOffset }
`

  const context = {
    module: { exports: {} },
    exports: {},
    matchMedia
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function media(matches) {
  return () => ({ matches })
}

test('prefersReducedMotion is false when the media query does not match', () => {
  const { prefersReducedMotion } = loadReducedMotion(media(false))

  assert.equal(prefersReducedMotion(), false)
})

test('prefersReducedMotion is true when the OS asks to reduce motion', () => {
  const { prefersReducedMotion } = loadReducedMotion(media(true))

  assert.equal(prefersReducedMotion(), true)
})

test('motionDuration returns token fallbacks when motion is allowed', () => {
  const { motionDuration } = loadReducedMotion(media(false))

  assert.equal(motionDuration('fast'), 150)
  assert.equal(motionDuration('base'), 200)
  assert.equal(motionDuration('slow'), 300)
})

test('motionDuration is 0 when motion is reduced', () => {
  const { motionDuration } = loadReducedMotion(media(true))

  assert.equal(motionDuration('fast'), 0)
  assert.equal(motionDuration('base'), 0)
  assert.equal(motionDuration('slow'), 0)
})

test('motionTransition builds duration and easing custom properties', () => {
  const { motionTransition } = loadReducedMotion(media(false))

  assert.equal(
    motionTransition('opacity', { duration: 'slow', easing: 'enter' }),
    'opacity var(--duration-slow) var(--easing-enter)'
  )
  assert.equal(
    motionTransition(['opacity', 'transform'], { duration: 'base', easing: 'exit' }),
    'opacity var(--duration-base) var(--easing-exit), transform var(--duration-base) var(--easing-exit)'
  )
})

test('overlay origin and enter offset follow placement', () => {
  const { overlayOrigin, overlayEnterOffset } = loadReducedMotion(media(false))

  assert.equal(overlayOrigin('top'), 'bottom center')
  assert.equal(overlayOrigin('bottom'), 'top center')
  assert.equal(overlayOrigin('left'), 'right center')
  assert.equal(overlayOrigin('right'), 'left center')
  assert.equal(overlayEnterOffset('top'), 'translateY(4px)')
  assert.equal(overlayEnterOffset('bottom'), 'translateY(-4px)')
  assert.equal(overlayEnterOffset('left'), 'translateX(4px)')
  assert.equal(overlayEnterOffset('right'), 'translateX(-4px)')
})
