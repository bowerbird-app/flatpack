# frozen_string_literal: true

module FlatPack
  module EmailFooterLinks
    class Component < FlatPack::BaseComponent
      ALIGNMENTS = %i[left center right].freeze
      DEFAULT_COLOR = "#6b7280"
      DEFAULT_FONT_SIZE = "12px"
      SAFE_SIZE_PATTERN = /\A\d+(?:\.\d+)?(?:px|em|rem|%)\z/

      def initialize(
        links:,
        align: :center,
        color: DEFAULT_COLOR,
        font_size: DEFAULT_FONT_SIZE,
        **system_arguments
      )
        super(**system_arguments)
        @links = normalize_links!(links)
        @align = align.to_sym
        @color = normalize_color!(color)
        @font_size = normalize_font_size!(font_size)

        validate_align!
      end

      def call
        content_tag(:table, **table_attributes) do
          content_tag(:tr) do
            content_tag(:td, safe_join(rendered_link_nodes), **cell_attributes)
          end
        end
      end

      private

      def table_attributes
        merge_attributes(
          role: "presentation",
          cellpadding: "0",
          cellspacing: "0",
          border: "0",
          width: "100%",
          style: "width:100%;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;"
        )
      end

      def cell_attributes
        {
          align: @align.to_s,
          style: [
            "padding:0",
            "Margin:0",
            "font-family:Arial,sans-serif",
            "font-size:#{@font_size}",
            "line-height:1.5",
            "color:#{@color}",
            "word-break:break-word"
          ].join(";")
        }
      end

      def rendered_link_nodes
        @links.each_with_index.flat_map do |link, index|
          href = link.fetch(:href)
          label = link.fetch(:label)

          nodes = [
            link_to(href, style: "color:#{@color};text-decoration:underline;display:inline;", title: label) do
              ERB::Util.html_escape(label)
            end
          ]
          nodes << content_tag(:span, " | ", style: "color:#{@color};") if index < @links.length - 1
          nodes
        end
      end

      def normalize_links!(links)
        array = Array(links)

        array.map do |link|
          link_hash = link.respond_to?(:to_h) ? link.to_h : {}
          label = link_hash[:label] || link_hash["label"]
          href = link_hash[:href] || link_hash["href"]

          raise ArgumentError, "links entries must include label and href" if label.blank? || href.blank?

          {label: label.to_s, href: FlatPack::AttributeSanitizer.validate_href!(href)}
        end
      end

      def validate_align!
        return if ALIGNMENTS.include?(@align)

        raise ArgumentError, "align must be one of: #{ALIGNMENTS.join(", ")}"
      end

      def normalize_color!(value)
        color = FlatPack::AttributeSanitizer.sanitize_css_color(value)
        return color if color.present?

        raise ArgumentError, "color must be a safe CSS color value"
      end

      def normalize_font_size!(value)
        font_size = value.to_s.strip
        return font_size if SAFE_SIZE_PATTERN.match?(font_size)

        raise ArgumentError, "font_size must be an email-safe CSS size"
      end
    end
  end
end
