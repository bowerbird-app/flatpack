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
    const data = google.visualization.arrayToDataTable([
      [regionLabel, valueLabel],
      ...this.geoRows()
    ])

    this.element.style.height = `${this.heightValue}px`
    this.element.style.width = "100%"
    this.chart = new google.visualization.GeoChart(this.element)
    this.chart.draw(data, chartOptions)
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
