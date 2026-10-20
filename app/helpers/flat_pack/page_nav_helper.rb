# frozen_string_literal: true

module FlatPack
  module PageNavHelper
    REQUEST_KEY = "flat_pack.page_nav"

    def flat_pack_page_nav(**kwargs, &block)
      request.env[REQUEST_KEY] = FlatPack::PageNav::Spec.new(**kwargs, &block)
      nil
    end

    def flat_pack_page_nav_tag
      spec = page_nav_spec
      return if spec.nil?

      kwargs = spec.to_component_kwargs
      return render(FlatPack::PageNav::Component.new(**kwargs)) if spec.links.empty?

      render(FlatPack::PageNav::Component.new(**kwargs)) do |nav|
        spec.links.each { |link| nav.with_link(**link) }
      end
    end

    def flat_pack_return_to_url(path)
      anchor = page_nav_anchor
      return path if anchor.blank?

      uri = URI.parse(path.to_s)
      pairs = URI.decode_www_form(uri.query.to_s)
      pairs.delete_if { |key, _value| key == "return_to" }
      pairs << ["return_to", anchor]
      uri.query = URI.encode_www_form(pairs)
      uri.to_s
    end

    def flat_pack_return_to_field
      anchor = page_nav_anchor
      return if anchor.blank?

      hidden_field_tag("return_to", anchor)
    end

    private

    def page_nav_spec
      stored = request.env[REQUEST_KEY]
      origin = FlatPack::ReturnTo.origin_url(controller)

      if stored
        stored.with_inbound_anchor(origin)
      elsif origin.present?
        FlatPack::PageNav::Spec.new(anchor_href: origin)
      end
    end

    def page_nav_anchor
      page_nav_spec&.to_component_kwargs&.[](:anchor_href)
    end
  end
end
