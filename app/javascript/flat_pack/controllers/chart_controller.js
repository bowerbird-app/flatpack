// FlatPack Chart Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    series: Array,
    type: { type: String, default: "line" },
    options: { type: Object, default: {} },
    height: { type: Number, default: 280 }
  }

  async connect() {
    // Dynamically import ApexCharts
    try {
      const ApexCharts = await this.loadApexCharts()
      await this.renderChart(ApexCharts)
    } catch (error) {
      console.error("Failed to load ApexCharts:", error)
      this.showError()
    }
  }

  disconnect() {
    // Destroy chart instance to prevent memory leaks
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  async loadApexCharts() {
    // Import ApexCharts from CDN via import maps
    const module = await import("apexcharts")
    return module.default || module
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
    this.chart = new ApexCharts(this.element, this.resolveCssColorOptions(options))
    return this.chart.render()
  }

  resolveCssColorOptions(value, key = null) {
    if (Array.isArray(value)) {
      return value.map((item) => this.resolveCssColorOptions(item, key))
    }

    if (value && typeof value === "object") {
      return Object.fromEntries(
        Object.entries(value).map(([childKey, childValue]) => [
          childKey,
          this.resolveCssColorOptions(childValue, childKey)
        ])
      )
    }

    if (typeof value === "string" && this.colorOptionKey(key)) {
      return this.resolveCssColor(value)
    }

    return value
  }

  colorOptionKey(key) {
    return ["background", "borderColor", "color", "colors", "foreColor", "gradientToColors"].includes(key)
  }

  resolveCssColor(value) {
    const probe = document.createElement("span")
    probe.style.color = value

    if (!probe.style.color) {
      return value
    }

    this.element.appendChild(probe)

    const resolvedColor = getComputedStyle(probe).color
    probe.remove()

    return this.normalizeColorForApex(resolvedColor) || resolvedColor || value
  }

  normalizeColorForApex(value) {
    const modernColor = this.normalizeModernCssColor(value)

    if (modernColor) {
      return modernColor
    }

    const canvas = document.createElement("canvas")
    const context = canvas.getContext("2d")

    if (!context) {
      return null
    }

    context.fillStyle = "#000"
    context.fillStyle = value

    return this.normalizeModernCssColor(context.fillStyle) || context.fillStyle
  }

  normalizeModernCssColor(value) {
    return this.normalizeOklabColor(value) || this.normalizeOklchColor(value) || this.normalizeSrgbColor(value)
  }

  normalizeOklabColor(value) {
    const match = value.match(/^oklab\(\s*([^\s]+)\s+([^\s]+)\s+([^\s/]+)(?:\s*\/\s*([^)]+))?\)$/)

    if (!match) {
      return null
    }

    return this.formatOklabColor(
      this.parseCssNumber(match[1]),
      this.parseCssNumber(match[2]),
      this.parseCssNumber(match[3]),
      this.parseCssAlpha(match[4])
    )
  }

  normalizeOklchColor(value) {
    const match = value.match(/^oklch\(\s*([^\s]+)\s+([^\s]+)\s+([^\s/]+)(?:\s*\/\s*([^)]+))?\)$/)

    if (!match) {
      return null
    }

    const lightness = this.parseCssNumber(match[1])
    const chroma = this.parseCssNumber(match[2])
    const hueRadians = this.parseHueDegrees(match[3]) * (Math.PI / 180)

    return this.formatOklabColor(
      lightness,
      chroma * Math.cos(hueRadians),
      chroma * Math.sin(hueRadians),
      this.parseCssAlpha(match[4])
    )
  }

  normalizeSrgbColor(value) {
    const match = value.match(/^color\(srgb\s+([^\s]+)\s+([^\s]+)\s+([^\s/]+)(?:\s*\/\s*([^)]+))?\)$/)

    if (!match) {
      return null
    }

    return this.formatRgbColor(
      Math.round(this.clamp(this.parseCssNumber(match[1])) * 255),
      Math.round(this.clamp(this.parseCssNumber(match[2])) * 255),
      Math.round(this.clamp(this.parseCssNumber(match[3])) * 255),
      this.parseCssAlpha(match[4])
    )
  }

  formatOklabColor(lightness, greenRed, blueYellow, alpha) {
    const longConeResponse = lightness + (0.3963377774 * greenRed) + (0.2158037573 * blueYellow)
    const mediumConeResponse = lightness - (0.1055613458 * greenRed) - (0.0638541728 * blueYellow)
    const shortConeResponse = lightness - (0.0894841775 * greenRed) - (1.2914855480 * blueYellow)

    const longSignal = longConeResponse ** 3
    const mediumSignal = mediumConeResponse ** 3
    const shortSignal = shortConeResponse ** 3

    const linearRed = (4.0767416621 * longSignal) - (3.3077115913 * mediumSignal) + (0.2309699292 * shortSignal)
    const linearGreen = (-1.2684380046 * longSignal) + (2.6097574011 * mediumSignal) - (0.3413193965 * shortSignal)
    const linearBlue = (-0.0041960863 * longSignal) - (0.7034186147 * mediumSignal) + (1.7076147010 * shortSignal)

    return this.formatRgbColor(
      Math.round(this.linearSrgbChannelToDisplay(linearRed) * 255),
      Math.round(this.linearSrgbChannelToDisplay(linearGreen) * 255),
      Math.round(this.linearSrgbChannelToDisplay(linearBlue) * 255),
      alpha
    )
  }

  linearSrgbChannelToDisplay(value) {
    const clampedValue = this.clamp(value)

    if (clampedValue <= 0.0031308) {
      return 12.92 * clampedValue
    }

    return (1.055 * (clampedValue ** (1 / 2.4))) - 0.055
  }

  formatRgbColor(red, green, blue, alpha = 1) {
    if (alpha < 1) {
      return `rgba(${red}, ${green}, ${blue}, ${Number(alpha.toFixed(3))})`
    }

    return `rgb(${red}, ${green}, ${blue})`
  }

  parseCssNumber(value) {
    if (value.endsWith("%")) {
      return Number.parseFloat(value) / 100
    }

    return Number.parseFloat(value)
  }

  parseCssAlpha(value) {
    if (!value) {
      return 1
    }

    return this.clamp(this.parseCssNumber(value))
  }

  parseHueDegrees(value) {
    if (value.endsWith("deg")) {
      return Number.parseFloat(value)
    }

    if (value.endsWith("turn")) {
      return Number.parseFloat(value) * 360
    }

    if (value.endsWith("rad")) {
      return Number.parseFloat(value) * (180 / Math.PI)
    }

    return Number.parseFloat(value)
  }

  clamp(value) {
    return Math.min(Math.max(value, 0), 1)
  }

  showError() {
    this.element.innerHTML = `
      <div class="flex items-center justify-center p-8 text-center">
        <div class="text-(--surface-muted-content-color)">
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
