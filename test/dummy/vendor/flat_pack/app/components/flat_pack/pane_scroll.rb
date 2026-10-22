# frozen_string_literal: true

module FlatPack
  # Hidden scroll bars for layout and panel panes. The width comes from
  # --pane-scrollbar-width. :visible opts one pane back to the browser bar.
  module PaneScroll
    VALUES = %i[hidden visible].freeze

    def self.normalize!(value)
      mode = value.is_a?(String) ? value.to_sym : value
      return mode if VALUES.include?(mode)

      raise ArgumentError, "scrollbar must be :hidden or :visible"
    end

    def self.attributes(class_name, label:, region: false, scrollbar: :hidden)
      attributes = {class: "#{class_name} fp-pane-scroll"}
      if scrollbar == :visible
        attributes[:data] = {pane_scrollbar: "visible"}
        return attributes
      end

      attributes[:tabindex] = "0"
      attributes[:aria] = {label: label}
      attributes[:role] = "region" if region
      attributes
    end
  end
end
