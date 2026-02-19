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
      this.renderChart(ApexCharts)
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
    this.chart = new ApexCharts(this.element, options)
    this.chart.render()
  }

  showError() {
    this.element.innerHTML = `
      <div class="flex items-center justify-center p-8 text-center">
        <div class="text-[var(--color-text-muted)]">
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
