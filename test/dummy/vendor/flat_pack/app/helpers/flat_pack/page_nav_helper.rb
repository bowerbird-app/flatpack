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

      render(FlatPack::PageNav::Component.new(**spec.to_component_kwargs)) do |nav|
        spec.items.each { |item| replay_page_nav_item(nav, item) }
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
      page_nav_spec&.anchor_href
    end

    def replay_page_nav_item(nav, item)
      case item.kind
      when :back
        nav.with_back(**item.options)
      when :close
        nav.with_close(**item.options)
      when :link
        nav.with_link(**item.options)
      when :action
        replay_page_nav_action(nav, item)
      when :html
        html = item.html
        nav.with_item { html }
      else
        raise ArgumentError, "Unknown page nav item: #{item.kind}"
      end
    end

    def replay_page_nav_action(nav, item)
      html = item.html
      if html.nil?
        nav.with_action(**item.options)
      else
        nav.with_action(**item.options) { html }
      end
    end
  end
end
