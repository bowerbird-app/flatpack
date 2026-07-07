// FlatPack Chart Stimulus Controller
import { Controller } from "@hotwired/stimulus"

const GOOGLE_CHARTS_LOADER_URL = "https://www.gstatic.com/charts/loader.js"
let googleChartsPromise = null

export default class extends Controller {
  static values = {
    series: Array,
    type: { type: String, default: "line" },
    options: { type: Object, default: {} },
    height: { type: Number, default: 280 }
  }

  async connect() {
    try {
      if (this.isGeoChart()) {
        const google = await this.loadGoogleCharts()
        this.renderGeoChart(google)
        return
      }

      const ApexCharts = await this.loadApexCharts()
      this.renderChart(ApexCharts)
    } catch (error) {
      console.error("Failed to load chart:", error)
      this.showError()
    }
  }

  disconnect() {
    // Destroy chart instance to prevent memory leaks
    if (this.chart) {
      if (typeof this.chart.destroy === "function") {
        this.chart.destroy()
      } else if (typeof this.chart.clearChart === "function") {
        this.chart.clearChart()
      }
      this.chart = null
    }
  }

  isGeoChart() {
    return this.typeValue === "geochart"
  }

  async loadApexCharts() {
    // Import ApexCharts from CDN via import maps
    const module = await import("apexcharts")
    return module.default || module
  }

  async loadGoogleCharts() {
    if (!googleChartsPromise) {
      googleChartsPromise = new Promise((resolve, reject) => {
        const loadGeoChart = () => {
          window.google.charts.load("current", { packages: ["geochart"] })
          window.google.charts.setOnLoadCallback(() => resolve(window.google))
        }

        if (window.google?.charts) {
          loadGeoChart()
          return
        }

        const script = document.createElement("script")
        script.src = GOOGLE_CHARTS_LOADER_URL
        script.async = true
        script.onload = loadGeoChart
        script.onerror = () => reject(new Error("Failed to load Google Charts"))
        document.head.appendChild(script)
      })
    }

    return googleChartsPromise
  }

  renderChart(ApexCharts) {
    const chartOptions = this.optionsValue.chart || {}
    const options = {
      ...this.optionsValue,
      series: this.seriesValue,
      chart: {
        ...chartOptions,
        type: this.typeValue,
        height: this.heightValue
      }
    }

    // Create and render chart
    this.chart = new ApexCharts(this.element, options)
    this.chart.render()
  }

  renderGeoChart(google) {
    const { regionLabel = "Region", valueLabel = this.geoSeriesName(), ...chartOptions } = this.optionsValue
    const resolvedChartOptions = this.resolveGeoChartColorOptions(chartOptions)
    const data = google.visualization.arrayToDataTable([
      [regionLabel, valueLabel],
      ...this.geoRows()
    ])

    this.element.style.height = `${this.heightValue}px`
    this.element.style.width = "100%"
    this.chart = new google.visualization.GeoChart(this.element)
    this.chart.draw(data, resolvedChartOptions)
  }

  resolveGeoChartColorOptions(options) {
    const resolvedOptions = { ...options }

    if (resolvedOptions.colorAxis?.colors) {
      resolvedOptions.colorAxis = {
        ...resolvedOptions.colorAxis,
        colors: resolvedOptions.colorAxis.colors.map((color) => this.resolveGeoChartColor(color))
      }
    }

    const colorOptionKeys = ["datalessRegionColor", "defaultColor"]
    colorOptionKeys.forEach((key) => {
      if (resolvedOptions[key]) {
        resolvedOptions[key] = this.resolveGeoChartColor(resolvedOptions[key])
      }
    })

    if (resolvedOptions.backgroundColor?.fill) {
      resolvedOptions.backgroundColor = {
        ...resolvedOptions.backgroundColor,
        fill: this.resolveGeoChartColor(resolvedOptions.backgroundColor.fill)
      }
    }

    return resolvedOptions
  }

  resolveGeoChartColor(color) {
    if (typeof color !== "string") return color

    const primaryOpacityMatch = color.match(/^color-mix\(in oklab, var\(--color-primary\) (\d+)%, transparent\)$/)
    if (primaryOpacityMatch) {
      return this.primaryColorShade(Number(primaryOpacityMatch[1]) / 100)
    }

    return this.computedColor(color)
  }

  primaryColorShade(opacity) {
    const primaryColor = this.computedColor("var(--color-primary)")
    const primaryChannels = this.colorChannels(primaryColor)
    if (!primaryChannels) return primaryColor

    const backgroundColor = this.computedColor("var(--surface-background-color)")
    const backgroundChannels = this.colorChannels(backgroundColor) || { red: 255, green: 255, blue: 255 }

    return this.rgbColor({
      red: this.blendColorChannel(primaryChannels.red, backgroundChannels.red, opacity),
      green: this.blendColorChannel(primaryChannels.green, backgroundChannels.green, opacity),
      blue: this.blendColorChannel(primaryChannels.blue, backgroundChannels.blue, opacity)
    })
  }

  colorChannels(color) {
    const rgbChannels = color.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*[\d.]+)?\)$/)
    if (rgbChannels) {
      return {
        red: Number(rgbChannels[1]),
        green: Number(rgbChannels[2]),
        blue: Number(rgbChannels[3])
      }
    }

    const hexChannels = color.match(/^#([\da-f]{3}|[\da-f]{6})$/i)
    if (!hexChannels) return null

    const hex = hexChannels[1].length === 3
      ? hexChannels[1].split("").map((channel) => `${channel}${channel}`).join("")
      : hexChannels[1]

    return {
      red: parseInt(hex.slice(0, 2), 16),
      green: parseInt(hex.slice(2, 4), 16),
      blue: parseInt(hex.slice(4, 6), 16)
    }
  }

  blendColorChannel(foreground, background, opacity) {
    return Math.round((foreground * opacity) + (background * (1 - opacity)))
  }

  rgbColor({ red, green, blue }) {
    return `rgb(${red}, ${green}, ${blue})`
  }

  computedColor(color) {
    const colorProbe = document.createElement("span")
    colorProbe.style.color = color
    colorProbe.style.display = "none"
    this.element.appendChild(colorProbe)

    const computedColor = window.getComputedStyle(colorProbe).color || color
    colorProbe.remove()

    return this.normalizedCanvasColor(computedColor)
  }

  normalizedCanvasColor(color) {
    const context = document.createElement("canvas").getContext("2d")
    if (!context) return color

    if (typeof context.fillRect !== "function" || typeof context.getImageData !== "function") {
      context.fillStyle = color
      return context.fillStyle || color
    }

    context.clearRect(0, 0, 1, 1)
    context.fillStyle = color
    context.fillRect(0, 0, 1, 1)

    const { data } = context.getImageData(0, 0, 1, 1)
    const [red, green, blue, alpha] = data
    if (alpha === 255) {
      return `rgb(${red}, ${green}, ${blue})`
    }

    const normalizedAlpha = Number((alpha / 255).toFixed(3))
    return `rgba(${red}, ${green}, ${blue}, ${normalizedAlpha})`
  }

  geoSeriesName() {
    if (Array.isArray(this.seriesValue) && this.seriesValue[0]?.name) {
      return this.seriesValue[0].name
    }

    return "Value"
  }

  geoRows() {
    return this.geoDataPoints().map((point) => {
      if (Array.isArray(point)) {
        return [String(point[0]), Number(point[1])]
      }

      const region = point.region || point.code || point.name || point.country
      const value = point.value ?? point.val ?? point.count ?? point.data
      return [String(region), Number(value)]
    }).filter(([region, value]) => region && Number.isFinite(value))
  }

  geoDataPoints() {
    if (Array.isArray(this.seriesValue) && Array.isArray(this.seriesValue[0]?.data)) {
      return this.seriesValue[0].data
    }

    return Array.isArray(this.seriesValue) ? this.seriesValue : []
  }

  showError() {
    this.element.innerHTML = `
      <div class="flex items-center justify-center p-8 text-center">
        <div style="color: var(--surface-muted-content-color)">
          <svg class="w-12 h-12 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <p class="text-sm">Failed to load chart</p>
          <p class="text-xs mt-1">Please check your internet connection</p>
        </div>
      </div>
    `
  }

  // Update chart data dynamically (optional enhancement)
  updateSeries(newSeries) {
    if (this.chart) {
      this.chart.updateSeries(newSeries)
    }
  }

  // Update chart options dynamically (optional enhancement)
  updateOptions(newOptions) {
    if (this.chart) {
      this.chart.updateOptions(newOptions)
    }
  }
}
