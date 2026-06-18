const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadChartController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'chart_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ChartController extends Controller') + '\nmodule.exports = ChartController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController() {
  const createdElements = []
  const document = {
    createElement(tagName) {
      if (tagName === 'canvas') {
        return {
          getContext() {
            return {
              fillStyle: ''
            }
          }
        }
      }

      const element = {
        style: {},
        removeCalled: false,
        remove() {
          this.removeCalled = true
        }
      }
      createdElements.push(element)
      return element
    }
  }

  const window = {
    getComputedStyle(element) {
      if (element.style.color === 'var(--color-primary)') {
        return { color: 'rgb(20, 40, 60)' }
      }

      if (element.style.color === 'var(--surface-background-color)') {
        return { color: 'rgb(250, 250, 250)' }
      }

      if (element.style.color === 'transparent') {
        return { color: 'rgba(0, 0, 0, 0)' }
      }

      return { color: element.style.color }
    }
  }

  const ChartController = loadChartController({ document, window })
  const controller = new ChartController()
  controller.element = {
    appendedElements: [],
    appendChild(element) {
      this.appendedElements.push(element)
    }
  }

  return { controller, createdElements }
}

test('resolveGeoChartColorOptions converts primary color-mix values to opaque shade colors', () => {
  const { controller, createdElements } = buildController()
  const options = {
    colorAxis: {
      colors: [
        'color-mix(in oklab, var(--color-primary) 10%, transparent)',
        'color-mix(in oklab, var(--color-primary) 100%, transparent)'
      ]
    },
    datalessRegionColor: 'color-mix(in oklab, var(--color-primary) 10%, transparent)',
    defaultColor: 'color-mix(in oklab, var(--color-primary) 30%, transparent)',
    backgroundColor: {
      fill: 'transparent'
    }
  }

  const resolvedOptions = controller.resolveGeoChartColorOptions(options)

  assert.deepEqual(resolvedOptions.colorAxis.colors, [
    'rgb(227, 229, 231)',
    'rgb(20, 40, 60)'
  ])
  assert.equal(resolvedOptions.datalessRegionColor, 'rgb(227, 229, 231)')
  assert.equal(resolvedOptions.defaultColor, 'rgb(181, 187, 193)')
  assert.equal(resolvedOptions.backgroundColor.fill, 'rgba(0, 0, 0, 0)')
  assert.notEqual(resolvedOptions.colorAxis, options.colorAxis)
  assert.notEqual(resolvedOptions.backgroundColor, options.backgroundColor)
  assert.ok(createdElements.every((element) => element.removeCalled))
})
