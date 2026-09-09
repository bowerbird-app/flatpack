const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadReducedMotion(matchMedia, extras = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'reduced_motion.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source.replaceAll('export function ', 'function ') + `
module.exports = { prefersReducedMotion, motionDuration, motionTransition, overlayOrigin, overlayEnterOffset, playOverlayEnter, playOverlayExit, cancelOverlayHide, ...(typeof playCollapseExit === "function" ? { playCollapseExit } : {}) }
`

  const context = {
    module: { exports: {} },
    exports: {},
    matchMedia,
    requestAnimationFrame: extras.requestAnimationFrame || ((callback) => callback()),
    setTimeout: extras.setTimeout || ((callback) => { callback(); return 1 }),
    clearTimeout: extras.clearTimeout || (() => {}),
    WeakMap,
    document: extras.document
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

function overlayElement() {
  const classes = new Set(['hidden'])

  return {
    classList: {
      add(name) { classes.add(name) },
      remove(name) { classes.delete(name) },
      contains(name) { return classes.has(name) }
    },
    style: {},
    offsetHeight: 1
  }
}

test('playOverlayEnter unhides and fades in from the trigger offset', () => {
  const frames = []
  const { playOverlayEnter } = loadReducedMotion(media(false), {
    requestAnimationFrame: (callback) => frames.push(callback)
  })
  const element = overlayElement()

  playOverlayEnter(element, { placement: 'bottom' })

  assert.equal(element.classList.contains('hidden'), false)
  assert.equal(element.style.opacity, '0')
  assert.equal(element.style.transform, 'translateY(-4px)')
  assert.match(element.style.transition, /--duration-base/)
  assert.match(element.style.transition, /--easing-enter/)

  frames.forEach((callback) => callback())

  assert.equal(element.style.opacity, '1')
  assert.equal(element.style.transform, 'none')
})

test('playOverlayEnter skips the spatial offset when motion is reduced', () => {
  const { playOverlayEnter } = loadReducedMotion(media(true))
  const element = overlayElement()

  playOverlayEnter(element, { placement: 'bottom' })

  assert.equal(element.style.transform, 'none')
})

test('playOverlayEnter runs beforeAnimate and keeps in-flight styles when interrupting', () => {
  const frames = []
  const { playOverlayEnter } = loadReducedMotion(media(false), {
    requestAnimationFrame: (callback) => frames.push(callback)
  })
  const element = overlayElement()
  element.classList.remove('hidden')
  element.style.opacity = '0.4'
  element.style.transform = 'translateY(-2px)'
  let beforeCalls = 0

  playOverlayEnter(element, {
    placement: 'bottom',
    interrupt: true,
    beforeAnimate: () => { beforeCalls += 1 }
  })

  assert.equal(beforeCalls, 1)
  assert.equal(element.style.opacity, '0.4')
  assert.equal(element.style.transform, 'translateY(-2px)')

  frames.forEach((callback) => callback())

  assert.equal(element.style.opacity, '1')
  assert.equal(element.style.transform, 'none')
})

test('playOverlayEnter resumes when a hide is still in flight', () => {
  let delayed = null
  const frames = []
  const { playOverlayEnter, playOverlayExit } = loadReducedMotion(media(false), {
    requestAnimationFrame: (callback) => frames.push(callback),
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 9
    },
    clearTimeout: () => { delayed = null }
  })
  const element = overlayElement()
  element.classList.remove('hidden')
  let hiddenCalls = 0

  playOverlayExit(element, {
    placement: 'bottom',
    onHidden: () => { hiddenCalls += 1 }
  })

  assert.equal(element.style.opacity, '0')
  assert.equal(delayed.ms, 200)

  playOverlayEnter(element, { placement: 'bottom' })

  assert.equal(delayed, null)
  assert.equal(element.classList.contains('hidden'), false)
  assert.equal(element.style.opacity, '0')

  frames.forEach((callback) => callback())

  assert.equal(element.style.opacity, '1')
  assert.equal(hiddenCalls, 0)
})

test('cancelOverlayHide prevents a pending hide', () => {
  let delayed = null
  const { playOverlayExit, cancelOverlayHide } = loadReducedMotion(media(false), {
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 4
    },
    clearTimeout: () => { delayed = null }
  })
  const element = overlayElement()
  element.classList.remove('hidden')
  let hiddenCalls = 0

  playOverlayExit(element, {
    placement: 'bottom',
    onHidden: () => { hiddenCalls += 1 }
  })

  assert.equal(cancelOverlayHide(element), true)
  assert.equal(delayed, null)
  assert.equal(element.classList.contains('hidden'), false)
  assert.equal(hiddenCalls, 0)
  assert.equal(cancelOverlayHide(element), false)
})

test('playOverlayExit fades out then hides after the token duration', () => {
  let delayed = null
  const { playOverlayExit } = loadReducedMotion(media(false), {
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 7
    }
  })
  const element = overlayElement()
  element.classList.remove('hidden')
  let hiddenCalls = 0

  const timeoutId = playOverlayExit(element, {
    placement: 'bottom',
    onHidden: () => { hiddenCalls += 1 }
  })

  assert.equal(timeoutId, 7)
  assert.equal(delayed.ms, 200)
  assert.equal(element.style.opacity, '0')
  assert.equal(element.style.transform, 'translateY(-4px)')
  assert.equal(element.classList.contains('hidden'), false)

  delayed.callback()

  assert.equal(element.classList.contains('hidden'), true)
  assert.equal(hiddenCalls, 1)
})

test('playOverlayExit hides on the next turn when motion is reduced', () => {
  let delayed = null
  const { playOverlayExit } = loadReducedMotion(media(true), {
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 1
    }
  })
  const element = overlayElement()
  element.classList.remove('hidden')

  playOverlayExit(element, { placement: 'bottom' })

  assert.equal(delayed.ms, 0)
  assert.equal(element.style.transform, 'none')
})

function collapseElement({ height = 40, width = 96 } = {}) {
  return {
    style: {},
    offsetHeight: height,
    offsetWidth: width
  }
}

test('playCollapseExit collapses both axes then calls onHidden', () => {
  let delayed = null
  const { playCollapseExit } = loadReducedMotion(media(false), {
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 3
    }
  })
  const element = collapseElement()
  let hiddenCalls = 0

  playCollapseExit(element, {
    axis: "both",
    onHidden: () => { hiddenCalls += 1 }
  })

  assert.equal(element.style.overflow, "hidden")
  assert.equal(element.style.opacity, "0")
  assert.equal(element.style.height, "0px")
  assert.equal(element.style.width, "0px")
  assert.match(element.style.transition, /--duration-slow/)
  assert.match(element.style.transition, /--easing-exit/)
  assert.equal(delayed.ms, 300)
  assert.equal(hiddenCalls, 0)

  delayed.callback()

  assert.equal(hiddenCalls, 1)
})

test('playCollapseExit on the block axis leaves width alone', () => {
  let delayed = null
  const { playCollapseExit } = loadReducedMotion(media(false), {
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 5
    }
  })
  const element = collapseElement()

  playCollapseExit(element, { axis: "block" })

  assert.equal(element.style.height, "0px")
  assert.equal(element.style.width, undefined)
  assert.equal(element.style.transform, undefined)
  assert.equal(delayed.ms, 300)
})

test('playCollapseExit skips measuring when motion is reduced', () => {
  let delayed = null
  const { playCollapseExit } = loadReducedMotion(media(true), {
    setTimeout: (callback, ms) => {
      delayed = { callback, ms }
      return 1
    }
  })
  const element = collapseElement()
  let hiddenCalls = 0

  playCollapseExit(element, {
    onHidden: () => { hiddenCalls += 1 }
  })

  assert.equal(delayed.ms, 0)
  assert.equal(element.style.height, undefined)
  delayed.callback()
  assert.equal(hiddenCalls, 1)
})
