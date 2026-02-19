# Chart Component

The Chart component provides easy integration with ApexCharts for rendering interactive, beautiful charts in your Rails application.

## Installation

The Chart component requires ApexCharts to be loaded. FlatPack automatically configures the import map for you:

```ruby
# config/importmap.rb (already configured)
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.esm.js"
```

No additional setup is required. The chart controller dynamically imports ApexCharts when needed.

## Basic Usage

### Simple Line Chart

```erb
<%= render FlatPack::Chart::Component.new(
  series: [
    { name: "Sales", data: [30, 40, 45, 50, 49, 60, 70] }
  ],
  title: "Monthly Sales",
  subtitle: "2024 Performance"
) %>
```

### Bar Chart

```erb
<%= render FlatPack::Chart::Component.new(
  series: [
    { name: "Revenue", data: [44, 55, 57, 56, 61, 58, 63] }
  ],
  type: :bar,
  title: "Revenue by Month"
) %>
```

### Donut Chart

```erb
<%= render FlatPack::Chart::Component.new(
  series: [44, 55, 13, 43],
  type: :donut,
  options: {
    labels: ["Product A", "Product B", "Product C", "Product D"]
  },
  title: "Product Distribution"
) %>
```

## Options

### Required

- `series:` - Array or Hash of data series for the chart. Format depends on chart type.

### Optional

- `type:` - Chart type (`:line`, `:bar`, `:area`, `:donut`, `:pie`, `:radar`). Default: `:line`
- `options:` - Hash of ApexCharts options to customize the chart. See [ApexCharts documentation](https://apexcharts.com/docs/)
- `height:` - Chart height in pixels. Default: `280`
- `card:` - Wrap chart in a Card component. Default: `true`
- `title:` - Chart title (when card is true)
- `subtitle:` - Chart subtitle (when card is true)

## Advanced Usage

### Custom Options

You can pass any ApexCharts options to customize the appearance and behavior:

```erb
<%= render FlatPack::Chart::Component.new(
  series: [
    { name: "Sales", data: [30, 40, 45, 50, 49, 60, 70] }
  ],
  options: {
    xaxis: {
      categories: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"]
    },
    colors: ["#3b82f6"],
    stroke: {
      curve: "smooth",
      width: 3
    },
    markers: {
      size: 5
    }
  },
  title: "Sales Trend"
) %>
```

### Multiple Series

```erb
<%= render FlatPack::Chart::Component.new(
  series: [
    { name: "Revenue", data: [44, 55, 57, 56, 61, 58, 63] },
    { name: "Expenses", data: [35, 41, 36, 26, 45, 48, 52] },
    { name: "Profit", data: [9, 14, 21, 30, 16, 10, 11] }
  ],
  type: :area,
  options: {
    xaxis: {
      categories: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"]
    },
    fill: {
      type: "gradient",
      gradient: {
        shadeIntensity: 1,
        opacityFrom: 0.7,
        opacityTo: 0.3
      }
    }
  },
  title: "Financial Overview",
  subtitle: "Revenue, Expenses, and Profit"
) %>
```

### With Actions and Footer

```erb
<%= render FlatPack::Chart::Component.new(
  series: [...],
  title: "Dashboard"
) do |chart| %>
  <% chart.with_actions do %>
    <%= render FlatPack::Button::Component.new(text: "Export", size: :sm, style: :ghost) %>
    <%= render FlatPack::Button::Component.new(text: "Refresh", size: :sm, style: :ghost) %>
  <% end %>
  
  <% chart.with_footer do %>
    <p class="text-sm text-[var(--color-text-muted)]">
      Last updated: <%= Time.current.strftime("%B %d, %Y") %>
    </p>
  <% end %>
<% end %>
```

### Without Card Wrapper

For inline charts or custom layouts:

```erb
<%= render FlatPack::Chart::Component.new(
  series: [...],
  card: false,
  height: 200
) %>
```

## Theming

The Chart component automatically inherits your FlatPack theme colors through CSS variables. Default colors are configured for light mode, and ApexCharts will use these:

```ruby
# Default theme configuration
{
  theme: { mode: "light" },
  grid: { borderColor: "var(--color-border)" },
  xaxis: {
    labels: { style: { colors: "var(--color-text-muted)" } }
  }
}
```

You can override these in the `options` parameter to match your brand colors.

## Turbo Compatibility

The Chart component is fully compatible with Turbo Drive and Turbo Frames. The Stimulus controller:

- Dynamically loads ApexCharts only when needed
- Properly destroys chart instances on disconnect to prevent memory leaks
- Handles Turbo navigation without issues

## Accessibility

While ApexCharts provides interactive charts, consider providing:

1. Alternative data tables for screen readers
2. Descriptive titles and labels
3. Color schemes that don't rely solely on color to convey information

## Performance

The Chart component uses dynamic imports to load ApexCharts only when a chart is rendered. This keeps your initial bundle size small. Charts are rendered client-side, so complex datasets may take a moment to render.

For large datasets, consider:
- Server-side data aggregation
- Pagination or time-range filters
- Simplified chart types (e.g., use line instead of scatter for many points)

## Examples

### Dashboard Grid

```erb
<%= render FlatPack::Grid::Component.new(cols: 2, gap: :lg) do %>
  <div>
    <%= render FlatPack::Chart::Component.new(
      series: [...],
      type: :line,
      title: "Revenue"
    ) %>
  </div>
  
  <div>
    <%= render FlatPack::Chart::Component.new(
      series: [...],
      type: :bar,
      title: "Orders"
    ) %>
  </div>
<% end %>
```

### Real-time Updates

You can update chart data dynamically using Stimulus actions:

```javascript
// In your own Stimulus controller
this.chartController = this.application.getControllerForElementAndIdentifier(
  this.chartElement,
  "flat-pack--chart"
)

// Update series
this.chartController.updateSeries(newSeriesData)

// Update options
this.chartController.updateOptions({ colors: ["#ff0000"] })
```

## Reference

- [ApexCharts Documentation](https://apexcharts.com/docs/)
- [ApexCharts Examples](https://apexcharts.com/javascript-chart-demos/)
- [Chart Types](https://apexcharts.com/docs/chart-types/line-chart/)
