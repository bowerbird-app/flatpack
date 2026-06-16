# frozen_string_literal: true

module FlatPack
  module Chart
    class Component < FlatPack::BaseComponent
      renders_one :actions
      renders_one :footer

      alias_method :actions_slot, :actions
      alias_method :footer_slot, :footer

      undef_method :with_actions, :with_actions_content,
        :with_footer, :with_footer_content

      TYPES = {
        line: :line,
        column: :column,
        bar: :bar,
        area: :area,
        donut: :donut,
        pie: :pie,
        radar: :radar,
        gauge: :gauge
      }.freeze

      PRIMARY_COLOR_OPACITY_STEPS = [100, 90, 70, 50, 30, 10].freeze
      AREA_LINE_OPACITY_STEPS = [100, 85, 70, 55, 40, 25].freeze

      def initialize(
        series:,
        type: :line,
        options: {},
        height: 280,
        card: true,
        title: nil,
        subtitle: nil,
        **system_arguments
      )
        super(**system_arguments)
        @series = series
        @type = type.to_sym
        @options = options
        @height = height
        @card = card
        @title = title
        @subtitle = subtitle

        validate_series!
        validate_type!
        validate_height!
      end

      def call
        if @card
          render_with_card
        else
          render_chart_only
        end
      end

      def top_right_slot(*args, **kwargs, &block)
        return actions_slot if args.empty? && kwargs.empty? && !block

        set_slot(:actions, nil, *args, **kwargs, &block)
      end

      def actions(*args, **kwargs, &block)
        warn_deprecated_api(:actions, :top_right_slot)
        top_right_slot(*args, **kwargs, &block)
      end

      def footer(*args, **kwargs, &block)
        return footer_slot if args.empty? && kwargs.empty? && !block

        set_slot(:footer, nil, *args, **kwargs, &block)
      end

      private

      def render_with_card
        render FlatPack::Card::Component.new(padding: :none) do |card|
          card.header do
            render_card_header
          end

          card.body do
            render_chart_container
          end

          if footer?
            card.footer do
              footer.to_s
            end
          end
        end
      end

      def render_card_header
        content_tag(:div, class: "flex items-start justify-between gap-4 p-6") do
          safe_join([
            render_titles,
            render_actions_section
          ].compact)
        end
      end

      def render_titles
        content_tag(:div) do
          safe_join([
            (@title ? content_tag(:h3, @title, class: "text-lg font-semibold text-[var(--surface-content-color)]") : nil),
            (@subtitle ? content_tag(:p, @subtitle, class: "mt-1 text-sm text-[var(--surface-muted-content-color)]") : nil)
          ].compact)
        end
      end

      def render_actions_section
        return nil unless actions?

        content_tag(:div, actions_slot, class: "flex gap-2")
      end

      def render_chart_only
        content_tag(:div, **container_attributes) do
          render_chart_container
        end
      end

      def render_chart_container
        content_tag(:div, nil, **chart_attributes)
      end

      def container_attributes
        merge_attributes(
          class: container_classes
        )
      end

      def container_classes
        classes("w-full")
      end

      def chart_attributes
        {
          data: {
            controller: "flat-pack--chart",
            "flat-pack--chart-series-value": chart_series_json,
            "flat-pack--chart-type-value": apex_chart_type,
            "flat-pack--chart-options-value": chart_options_json,
            "flat-pack--chart-height-value": @height
          }
        }
      end

      def chart_series_json
        @series.to_json
      end

      def chart_options_json
        merged_options.to_json
      end

      def merged_options
        default_options.deep_merge(@options)
      end

      def default_options
        base_options = {
          chart: {
            fontFamily: "inherit",
            toolbar: {
              show: false
            }
          },
          colors: default_chart_colors,
          theme: {
            mode: "light"
          },
          dataLabels: {
            enabled: false
          },
          legend: {
            labels: {
              colors: "var(--surface-content-color)"
            }
          },
          tooltip: {
            theme: "light"
          }
        }

        return base_options.merge(gauge_chart_defaults) if gauge_chart?

        return base_options.merge(non_axis_chart_defaults) if non_axis_chart?

        base_options.merge(axis_chart_defaults)
      end

      def default_chart_colors
        PRIMARY_COLOR_OPACITY_STEPS.map do |opacity|
          "color-mix(in oklab, var(--color-primary) #{opacity}%, transparent)"
        end
      end

      def area_line_colors
        AREA_LINE_OPACITY_STEPS.map do |opacity|
          "color-mix(in oklab, var(--color-primary) #{opacity}%, transparent)"
        end
      end

      def axis_chart_defaults
        defaults = {
          stroke: {
            curve: "smooth",
            width: 2
          },
          grid: {
            borderColor: "var(--surface-border-color)",
            strokeDashArray: 4
          },
          xaxis: {
            labels: {
              style: {
                colors: "var(--surface-muted-content-color)"
              }
            },
            axisBorder: {
              color: "var(--surface-border-color)"
            },
            axisTicks: {
              color: "var(--surface-border-color)"
            }
          },
          yaxis: {
            labels: {
              style: {
                colors: "var(--surface-muted-content-color)"
              }
            }
          }
        }

        if area_chart?
          defaults = defaults.deep_merge(
            {
              colors: area_line_colors,
              fill: {
                type: "solid",
                colors: ["color-mix(in oklab, var(--color-primary) 10%, transparent)"],
                opacity: 1
              }
            }
          )
        end

        return defaults unless bar_chart?

        defaults.deep_merge(
          {
            plotOptions: {
              bar: {
                horizontal: horizontal_bar?
              }
            }
          }
        )
      end

      def non_axis_chart_defaults
        {
          stroke: {
            width: 1
          }
        }
      end

      def gauge_chart_defaults
        {
          colors: ["color-mix(in oklab, var(--color-primary) 100%, transparent)"],
          stroke: {
            lineCap: "round"
          },
          fill: {
            type: "gradient",
            gradient: {
              shade: "light",
              shadeIntensity: 0.45,
              inverseColors: false,
              gradientToColors: ["color-mix(in oklab, var(--color-primary) 70%, transparent)"],
              opacityFrom: 1,
              opacityTo: 1,
              stops: [0, 70, 100]
            }
          },
          plotOptions: {
            radialBar: {
              startAngle: -135,
              endAngle: 135,
              hollow: {
                size: "66%",
                background: "transparent"
              },
              track: {
                background: "color-mix(in oklab, var(--color-primary) 18%, transparent)",
                strokeWidth: "100%",
                margin: 0
              },
              dataLabels: {
                name: {
                  show: false
                },
                value: {
                  offsetY: 8,
                  fontSize: "2rem",
                  fontWeight: 700,
                  color: "var(--surface-content-color)"
                }
              }
            }
          }
        }
      end

      def non_axis_chart?
        @type == :donut || @type == :pie
      end

      def gauge_chart?
        @type == :gauge
      end

      def bar_chart?
        @type == :bar || @type == :column
      end

      def area_chart?
        @type == :area
      end

      def horizontal_bar?
        @type == :bar
      end

      def apex_chart_type
        return :radialBar if gauge_chart?
        return :bar if bar_chart?

        @type
      end

      def validate_series!
        return if @series.is_a?(Array) || @series.is_a?(Hash)
        raise ArgumentError, "series must be an Array or Hash"
      end

      def validate_type!
        return if TYPES.key?(@type)
        raise ArgumentError, "Invalid type: #{@type}. Must be one of: #{TYPES.keys.join(", ")}"
      end

      def validate_height!
        return if @height.is_a?(Integer) && @height > 0
        raise ArgumentError, "height must be a positive integer"
      end
    end
  end
end
