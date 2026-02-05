# frozen_string_literal: true

module FlatPack
  module Table
    class ActionComponent < ViewComponent::Base
      def initialize(text: nil, icon: nil, url: nil, method: nil, style: :ghost, html: nil, **system_arguments, &block)
        @text = text
        @icon = icon
        @url = url
        @method = method
        @style = style
        @html = html || block
        @system_arguments = system_arguments
      end

      def render_action(row)
        if @html
          # Call the html proc/lambda
          @html.call(row)
        else
          # Return a Button component instance that can be rendered by the parent
          FlatPack::Button::Component.new(
            text: action_text(row),
            url: action_url(row),
            method: @method,
            style: @style,
            **@system_arguments
          )
        end
      end

      private

      def action_text(row)
        if @text.respond_to?(:call)
          @text.call(row)
        else
          @text
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
