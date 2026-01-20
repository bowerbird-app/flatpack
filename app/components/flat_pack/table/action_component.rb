# frozen_string_literal: true

module FlatPack
  module Table
    class ActionComponent < ViewComponent::Base
      def initialize(label: nil, icon: nil, url: nil, method: nil, scheme: :ghost, formatter: nil, **system_arguments, &block)
        @label = label
        @icon = icon
        @url = url
        @method = method
        @scheme = scheme
        @formatter = formatter || block
        @system_arguments = system_arguments
      end

      def render_action(row)
        if @formatter
          # Call the formatter proc/lambda
          @formatter.call(row)
        else
          # Return a Button component instance that can be rendered by the parent
          FlatPack::Button::Component.new(
            label: action_label(row),
            url: action_url(row),
            method: @method,
            scheme: @scheme,
            **@system_arguments
          )
        end
      end

      private

      def action_label(row)
        if @label.respond_to?(:call)
          @label.call(row)
        else
          @label
        end
      end

      def action_url(row)
        if @url.respond_to?(:call)
          @url.call(row)
        else
          @url
        end
      end
    end
  end
end
