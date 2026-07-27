# frozen_string_literal: true

module FlatPack
  module EmailButton
    class Component < FlatPack::BaseComponent
      ALIGNMENTS = %i[left center right].freeze
      VARIANTS = %i[primary secondary].freeze

      VARIANT_STYLES = {
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
        label:,
        variant: :primary,
        align: :center,
        full_width: false,
        **system_arguments
      )
        @href = FlatPack::AttributeSanitizer.validate_href!(href)
        @label = label.to_s
        @variant = variant.to_sym
        @align = align.to_sym
        @full_width = full_width
        super(**system_arguments)

        validate_variant!
        validate_align!
        validate_label!
      end

      def call
        content_tag(:table, **outer_table_attributes) do
          content_tag(:tr) do
            content_tag(:td, **button_cell_attributes) do
              link_to(@href, style: link_style) { ERB::Util.html_escape(@label) }
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
          style: "border-collapse:separate;mso-table-lspace:0pt;mso-table-rspace:0pt;#{table_width_style}"
        )
      end

      def button_cell_attributes
        styles = VARIANT_STYLES.fetch(@variant)
        {
          align: @align.to_s,
          bgcolor: styles.fetch(:background),
          style: [
            "border-radius:6px",
            "background-color:#{styles.fetch(:background)}",
            "border:1px solid #{styles.fetch(:border)}",
            "text-align:center"
          ].join(";")
        }
      end

      def link_style
        styles = VARIANT_STYLES.fetch(@variant)
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
          "color:#{styles.fetch(:color)}",
          "background-color:#{styles.fetch(:background)}",
          "border:1px solid #{styles.fetch(:border)}",
          "border-radius:6px",
          "mso-line-height-rule:exactly"
        ].compact.join(";")
      end

      def table_width_style
        @full_width ? "width:100%;" : "width:auto;"
      end

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "variant must be one of: #{VARIANTS.join(", ")}"
      end

      def validate_align!
        return if ALIGNMENTS.include?(@align)

        raise ArgumentError, "align must be one of: #{ALIGNMENTS.join(", ")}"
      end

      def validate_label!
        return if @label.present?

        raise ArgumentError, "label must be present"
      end
    end
  end
end
