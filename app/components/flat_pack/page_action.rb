# frozen_string_literal: true

module FlatPack
  # One nominated page action. The view chooses the label, the path, the icon,
  # and the role. It does not choose placement or a button style.
  class PageAction
    ROLES = %i[primary secondary destructive].freeze

    attr_reader :label, :href, :role, :icon, :data, :aria

    def initialize(label, href, role: :secondary, icon: nil, data: nil, aria: nil)
      @label = label.to_s
      @role = role.to_sym
      @icon = icon
      @data = data
      @aria = aria
      @href = safe_href!(href)

      validate_label!
      validate_role!
    end

    private

    def safe_href!(href)
      raise ArgumentError, "page action needs a path" if href.blank?

      safe = FlatPack::AttributeSanitizer.sanitize_url(href)
      return safe if safe.present?

      raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
    end

    def validate_label!
      return if @label.present?

      raise ArgumentError, "page action needs a label"
    end

    def validate_role!
      return if ROLES.include?(@role)

      raise ArgumentError, "role must be :primary, :secondary, or :destructive"
    end
  end
end
