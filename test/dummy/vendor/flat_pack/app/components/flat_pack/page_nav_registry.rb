# frozen_string_literal: true

module FlatPack
  # Page nav items registered during one request, in source order.
  # Hold an instance on the request. Do not keep one on the class.
  class PageNavRegistry
    def initialize
      @items = []
      @claimed = []
    end

    def add(item)
      @items << item
      nil
    end

    def items
      @items.dup
    end

    def empty?
      @items.empty?
    end

    # Each component entry renders once. A later call does not copy it, so a
    # Turbo Stream can target the component's wrapper id.
    def claim_components
      pending = @items.select { |item| item.component? && !@claimed.include?(item) }
      @claimed.concat(pending)
      pending
    end
  end
end
