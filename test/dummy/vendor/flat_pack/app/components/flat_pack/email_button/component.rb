# frozen_string_literal: true

module FlatPack
  module EmailButton
    class Component < FlatPack::BaseComponent
      ALIGNMENTS = %i[left center right].freeze
      STYLE_VALUES = %i[primary secondary].freeze

      STYLES = {
        primary: {
          background: "#2563eb",
          border: "#2563eb",
          color: "#ffffff"
        },
        secondary: {
          background: "#f3f4f6",
          border: "#d1d5db",
          color: "#374151"
        }
      }.freeze

      def initialize(
        href:,
        text:,
        style: :primary,
        align: :center,
        full_width: false,
        fit_content: false,
        **system_arguments
      )
        @href = FlatPack::AttributeSanitizer.validate_href!(href)
        @text = text.to_s
        @style = style.to_sym
        @align = align.to_sym
        @full_width = full_width
        @fit_content = fit_content
        super(**system_arguments)

        validate_width_options!
        validate_style!
        validate_align!
        validate_text!
      end

      def call
        content_tag(:table, **outer_table_attributes) do
          content_tag(:tr) do
            content_tag(:td, **button_cell_attributes) do
              link_to(@href, style: link_style) { ERB::Util.html_escape(@text) }
            end
          end
        end
      end

      private

      def outer_table_attributes
        merge_attributes(
          role: "presentation",
          cellpadding: "0",
          cellspacing: "0",
          border: "0",
          width: (@full_width ? "100%" : nil),
          style: "border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;#{table_width_style};#{table_display_style}"
        )
      end

      def button_cell_attributes
        styles = STYLES.fetch(@style)
        {
          align: @align.to_s,
          bgcolor: styles.fetch(:background),
          style: [
            "border-radius:6px",
            "background-color:#{styles.fetch(:background)}",
            theme_background_override,
            "border:1px solid #{styles.fetch(:border)}",
            theme_border_override,
            "text-align:#{@align}"
          ].compact.join(";")
        }
      end

      def link_style
        styles = STYLES.fetch(@style)
        [
          "display:#{@full_width ? "block" : "inline-block"}",
          (@full_width ? "width:100%" : nil),
          "box-sizing:border-box",
          "padding:12px 20px",
          "font-family:Arial,sans-serif",
          "font-size:16px",
          "line-height:20px",
          "font-weight:700",
          "text-decoration:none",
          "text-align:#{@align}",
          "color:#{styles.fetch(:color)}",
          theme_text_color_override,
          "background-color:#{styles.fetch(:background)}",
          theme_background_override,
          "border:1px solid #{styles.fetch(:border)}",
          theme_border_override,
          "border-radius:6px",
          "mso-line-height-rule:exactly"
        ].compact.join(";")
      end

      def theme_background_override
        return unless %i[primary secondary].include?(@style)

        "background-color:var(--button-#{@style}-background-color, #{STYLES.fetch(@style).fetch(:background)})"
      end

      def theme_border_override
        return unless %i[primary secondary].include?(@style)

        "border:1px solid var(--button-#{@style}-border-color, #{STYLES.fetch(@style).fetch(:border)})"
      end

      def theme_text_color_override
        return unless %i[primary secondary].include?(@style)

        "color:var(--button-#{@style}-text-color, #{STYLES.fetch(@style).fetch(:color)})"
      end

      def table_width_style
        @full_width ? "width:100%;" : "width:auto;"
      end

      def table_display_style
        @fit_content ? "display:inline-table;" : "display:table;"
      end

      def validate_width_options!
        return unless @full_width && @fit_content

        raise ArgumentError, "full_width and fit_content cannot both be true"
      end

      def validate_style!
        return if STYLE_VALUES.include?(@style)

        raise ArgumentError, "style must be one of: #{STYLE_VALUES.join(", ")}"
      end

      def validate_align!
        return if ALIGNMENTS.include?(@align)

        raise ArgumentError, "align must be one of: #{ALIGNMENTS.join(", ")}"
      end

      def validate_text!
        return if @text.present?

        raise ArgumentError, "text must be present"
      end
    end
  end
end
