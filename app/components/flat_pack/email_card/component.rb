# frozen_string_literal: true

module FlatPack
  module EmailCard
    class Component < FlatPack::BaseComponent
      ALIGNMENTS = %i[left center right].freeze
      DEFAULT_MAX_WIDTH = 600
      DEFAULT_PADDING = "24px"
      DEFAULT_BACKGROUND = "#ffffff"
      DEFAULT_BORDER = "#e5e7eb"
      DEFAULT_TEXT = "#111827"
      SAFE_SPACING_PATTERN = /\A\d+(?:\.\d+)?(?:px|em|rem|%)(?:\s+\d+(?:\.\d+)?(?:px|em|rem|%)){0,3}\z/

      def initialize(
        max_width: DEFAULT_MAX_WIDTH,
        padding: DEFAULT_PADDING,
        bg_color: DEFAULT_BACKGROUND,
        border_color: DEFAULT_BORDER,
        align: :center,
        **system_arguments
      )
        super(**system_arguments)
        @max_width = Integer(max_width)
        @padding = normalize_spacing!(padding)
        @bg_color = normalize_color!(bg_color, :bg_color)
        @border_color = normalize_color!(border_color, :border_color)
        @default_bg_color = (@bg_color == DEFAULT_BACKGROUND)
        @default_border_color = (@border_color == DEFAULT_BORDER)
        @align = align.to_sym

        validate_max_width!
        validate_align!
      end

      def call
        content_tag(:table, **outer_table_attributes) do
          content_tag(:tr) do
            content_tag(:td, align: @align.to_s, style: "padding:0;Margin:0;") do
              content_tag(:table, **inner_table_attributes) do
                content_tag(:tr) do
                  content_tag(:td, content, style: card_cell_style)
                end
              end
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
          width: "100%",
          style: "width:100%;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;"
        )
      end

      def inner_table_attributes
        {
          role: "presentation",
          cellpadding: "0",
          cellspacing: "0",
          border: "0",
          width: "100%",
          style: "width:100%;max-width:#{@max_width}px;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;#{alignment_style}"
        }
      end

      def card_cell_style
        [
          "padding:#{@padding}",
          "background-color:#{@bg_color}",
          theme_background_override,
          "border:1px solid #{@border_color}",
          theme_border_override,
          "border-radius:8px",
          "font-family:Arial,sans-serif",
          "color:#{DEFAULT_TEXT}",
          theme_text_color_override
        ].compact.join(";")
      end

      def theme_background_override
        return unless @default_bg_color

        "background-color:var(--card-background-color, var(--surface-background-color, #{@bg_color}))"
      end

      def theme_border_override
        return unless @default_border_color

        "border:1px solid var(--card-border-color, var(--surface-border-color, #{@border_color}))"
      end

      def theme_text_color_override
        "color:var(--surface-content-color, #{DEFAULT_TEXT})"
      end

      def alignment_style
        case @align
        when :left
          "margin-left:0;margin-right:auto;"
        when :right
          "margin-left:auto;margin-right:0;"
        else
          "margin-left:auto;margin-right:auto;"
        end
      end

      def validate_max_width!
        return if @max_width.positive?

        raise ArgumentError, "max_width must be greater than 0"
      end

      def validate_align!
        return if ALIGNMENTS.include?(@align)

        raise ArgumentError, "align must be one of: #{ALIGNMENTS.join(", ")}"
      end

      def normalize_spacing!(value)
        string_value = value.to_s.strip
        return string_value if SAFE_SPACING_PATTERN.match?(string_value)

        raise ArgumentError, "padding must be email-safe spacing values (px, em, rem, %)"
      end

      def normalize_color!(value, name)
        sanitized = FlatPack::AttributeSanitizer.sanitize_css_color(value)
        return sanitized if sanitized.present?

        raise ArgumentError, "#{name} must be a safe CSS color value"
      end
    end
  end
end
