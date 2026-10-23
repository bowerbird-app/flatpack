# frozen_string_literal: true

module FlatPack
  # One registered page nav entry. A semantic link, or a component the gem
  # already built. Role is required. It does not choose a button style.
  class PageNavItem
    ROLES = %i[primary secondary destructive].freeze

    attr_reader :label, :href, :role, :icon, :data, :aria, :component, :overflow

    def initialize(label = nil, href = nil, role:, icon: nil, data: nil, aria: nil, component: nil, overflow: nil)
      @role = normalize_role!(role)
      @overflow = normalize_overflow!(overflow)
      if component
        reject_semantic!(label, href, icon, data, aria)
        @component = component
      else
        @label = label.to_s
        @icon = icon
        @data = data
        @aria = aria
        @href = safe_href!(href)
        validate_label!
      end
    end

    def component?
      !@component.nil?
    end

    private

    def normalize_role!(role)
      name = role.to_sym if role.respond_to?(:to_sym)
      return name if ROLES.include?(name)

      raise ArgumentError, "role must be :primary, :secondary, or :destructive"
    end

    def reject_semantic!(label, href, icon, data, aria)
      return if label.nil? && href.nil? && icon.nil? && data.nil? && aria.nil?

      raise ArgumentError, "page nav component takes role: and overflow: only"
    end

    def normalize_overflow!(value)
      return if value.nil?
      return value if value == true || value == false

      raise ArgumentError, "overflow must be true or false"
    end

    def safe_href!(href)
      raise ArgumentError, "page nav needs a path" if href.blank?

      safe = FlatPack::AttributeSanitizer.sanitize_url(href)
      return safe if safe.present?

      raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
    end

    def validate_label!
      return if @label.present?

      raise ArgumentError, "page nav needs a label"
    end
  end
end
