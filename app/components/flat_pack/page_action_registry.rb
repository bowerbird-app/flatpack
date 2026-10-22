# frozen_string_literal: true

module FlatPack
  # Actions nominated during one request, in source order.
  # Hold an instance on the request. Do not keep one on the class.
  class PageActionRegistry
    def initialize
      @actions = []
    end

    def add(action)
      @actions << action
      nil
    end

    def actions
      @actions.dup
    end

    def empty?
      @actions.empty?
    end
  end
end
