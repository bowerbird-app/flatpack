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
  const canvasContext = {
    fillStyle: '',
    clearRect() {},
    fillRect() {},
    getImageData() {
      if (this.fillStyle === 'oklch(0.3211 0 0)') {
        return { data: [52, 52, 52, 255] }
      }

      if (this.fillStyle === 'transparent') {
        return { data: [0, 0, 0, 0] }
      }

      const rgbMatch = this.fillStyle.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)$/)
      if (rgbMatch) {
        const alpha = rgbMatch[4] ? Math.round(Number(rgbMatch[4]) * 255) : 255
        return {
          data: [Number(rgbMatch[1]), Number(rgbMatch[2]), Number(rgbMatch[3]), alpha]
        }
      }

      return { data: [20, 40, 60, 255] }
    }
  }

  const document = {
    createElement(tagName) {
      if (tagName === 'canvas') {
        return {
          getContext() {
            return canvasContext
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

test('geoRows accepts country code region values', () => {
  const { controller } = buildController()
  controller.seriesValue = [{
    name: 'Active accounts',
    data: [
      { region: 'AU', value: 58 },
      { code: 'US', value: 225 },
      { country: 'MY', count: 44 },
      ['TH', 39]
    ]
  }]

  assert.equal(JSON.stringify(controller.geoRows()), JSON.stringify([
    ['AU', 58],
    ['US', 225],
    ['MY', 44],
    ['TH', 39]
  ]))
})

test('renderChart leaves axis options alone when integerTicksValue is false', () => {
  const { controller } = buildController()
  let captured = null
  class ApexCharts {
    constructor(_element, options) {
      captured = options
    }
    render() {}
  }

  controller.seriesValue = [{ name: 'Jobs', data: [0, 1, 2] }]
  controller.typeValue = 'line'
  controller.optionsValue = { yaxis: { labels: { style: { colors: 'red' } } } }
  controller.heightValue = 280
  controller.integerTicksValue = false
  controller.renderChart(ApexCharts)

  assert.equal(captured.yaxis.stepSize, undefined)
  assert.equal(captured.yaxis.decimalsInFloat, undefined)
  assert.equal(captured.yaxis.labels.formatter, undefined)
  assert.equal(captured.yaxis.labels.style.colors, 'red')
})

test('renderChart applies integer tick options when integerTicksValue is true', () => {
  const { controller } = buildController()
  let captured = null
  class ApexCharts {
    constructor(_element, options) {
      captured = options
    }
    render() {}
  }

  controller.seriesValue = [{ name: 'Jobs', data: [0, 1, 2] }]
  controller.typeValue = 'bar'
  controller.optionsValue = {
    yaxis: { labels: { style: { colors: 'red' } } },
    xaxis: { categories: ['Mon', 'Tue', 'Wed'] }
  }
  controller.heightValue = 280
  controller.integerTicksValue = true
  controller.renderChart(ApexCharts)

  assert.equal(captured.yaxis.stepSize, 1)
  assert.equal(captured.yaxis.decimalsInFloat, 0)
  assert.equal(captured.yaxis.labels.style.colors, 'red')
  assert.equal(captured.yaxis.labels.formatter(0.0), '0')
  assert.equal(captured.yaxis.labels.formatter(1.5), '2')
  assert.equal(captured.xaxis.stepSize, undefined)
  assert.equal(captured.xaxis.categories[0], 'Mon')
})

test('integer ticks wrap an existing yaxis formatter with rounded values', () => {
  const { controller } = buildController()
  const axis = controller.integerAxis({
    labels: {
      formatter(val) {
        return `n=${val}`
      }
    }
  })

  assert.equal(axis.labels.formatter(1.5), 'n=2')
  assert.equal(axis.stepSize, 1)
})

test('integer ticks skip a non-numeric xaxis and keep a numeric xaxis', () => {
  const { controller } = buildController()
  const categoryAxis = controller.integerAxis({ type: 'category' }, { numericOnly: true })
  const numericAxis = controller.integerAxis({ type: 'numeric' }, { numericOnly: true })

  assert.equal(categoryAxis.stepSize, undefined)
  assert.equal(numericAxis.stepSize, 1)
  assert.equal(numericAxis.labels.formatter('3.2'), '3')
})

test('normalizedCanvasColor returns rgb-compatible color strings', () => {
  const { controller } = buildController()

  assert.equal(controller.normalizedCanvasColor('oklch(0.3211 0 0)'), 'rgb(52, 52, 52)')
  assert.equal(controller.normalizedCanvasColor('transparent'), 'rgba(0, 0, 0, 0)')
})
