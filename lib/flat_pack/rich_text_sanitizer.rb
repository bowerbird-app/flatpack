# frozen_string_literal: true

module FlatPack
  module RichTextSanitizer
    ALLOWED_TAGS = %w[
      p br hr
      h1 h2 h3 h4 h5 h6
      strong em u s sub sup
      ul ol li
      blockquote pre code
      mark span a img
      table thead tbody tr th td
      div
    ].freeze

    ALLOWED_ATTRIBUTES = {
      "all" => %w[class],
      "a" => %w[href rel target],
      "img" => %w[src alt title width height],
      "mark" => %w[data-color style],
      "span" => %w[style],
      "p" => %w[style],
      "h1" => %w[style],
      "h2" => %w[style],
      "h3" => %w[style],
      "h4" => %w[style],
      "h5" => %w[style],
      "h6" => %w[style],
      "code" => %w[class],
      "ul" => %w[data-type],
      "li" => %w[data-checked],
      "th" => %w[colspan rowspan style data-colwidth],
      "td" => %w[colspan rowspan style data-colwidth]
    }.freeze

    def self.sanitize(html)
      ActionController::Base.helpers.sanitize(
        html,
        tags: ALLOWED_TAGS,
        attributes: ALLOWED_ATTRIBUTES.values.flatten.uniq
      )
    end
  end
end
