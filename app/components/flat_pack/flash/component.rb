# frozen_string_literal: true

module FlatPack
  module Flash
    class Component < FlatPack::BaseComponent
      AS = %i[alert toast].freeze

      DEFAULT_STYLES = {
        notice: :success,
        alert: :danger,
        warning: :warning,
        info: :info,
        success: :success,
        error: :danger,
        danger: :danger
      }.freeze

      def initialize(flash:, as:, styles: {}, **system_arguments)
        @forwarded_arguments = system_arguments.dup
        super(**system_arguments)
        @flash = flash
        @as = as.to_s.to_sym
        @styles = DEFAULT_STYLES.merge(normalize_styles(styles))

        validate_flash!
        validate_mode!
      end

      def render?
        entries.any?
      end

      def call
        (@as == :toast) ? render_toasts : render_alerts
      end

      private

      def render_alerts
        content_tag(:div, safe_join(alert_nodes), **alert_stack_attributes)
      end

      def alert_stack_attributes
        merge_attributes(class: "flex flex-col gap-4")
      end

      def alert_nodes
        entries.map do |style, text|
          render(FlatPack::Alert::Component.new(description: text, style: style))
        end
      end

      def render_toasts
        region = FlatPack::Toasts::Region::Component.new(**@forwarded_arguments)
        region.with_content(safe_join(toast_nodes))
        render(region)
      end

      def toast_nodes
        entries.map do |style, text|
          render(FlatPack::Toast::Component.new(text: text, style: style))
        end
      end

      def entries
        @entries ||= build_entries
      end

      def build_entries
        messages = []

        each_flash_pair do |key, value|
          texts_from(value).each do |text|
            messages << [style_for(key), text]
          end
        end

        messages
      end

      def each_flash_pair(&block)
        if @flash.respond_to?(:each_pair)
          @flash.each_pair(&block)
        else
          @flash.each(&block)
        end
      end

      def texts_from(value)
        items = value.is_a?(Array) ? value : [value]
        items.filter_map { |item| plain_text(item) }
      end

      def plain_text(item)
        return unless item.is_a?(String)

        text = item.html_safe? ? String.new(item) : item
        return if text.blank?

        text
      end

      def style_for(key)
        @styles.fetch(key.to_s.to_sym, :info)
      end

      def normalize_styles(styles)
        unless styles.is_a?(Hash)
          raise ArgumentError, "styles must be a Hash"
        end

        styles.each_with_object({}) do |(key, value), normalized|
          style = value.to_s.to_sym
          unless allowed_styles.include?(style)
            raise ArgumentError, "Invalid style: #{value}. Must be one of: #{allowed_styles.join(", ")}"
          end

          normalized[key.to_s.to_sym] = style
        end
      end

      def allowed_styles
        @allowed_styles ||= FlatPack::Alert::Component::VARIANTS.keys & FlatPack::Toast::Component::STYLES.keys
      end

      def validate_flash!
        return if @flash.respond_to?(:each_pair)
        return if @flash.respond_to?(:each) && !@flash.is_a?(String) && !@flash.is_a?(Array)

        raise ArgumentError, "flash must be a Hash"
      end

      def validate_mode!
        return if AS.include?(@as)

        raise ArgumentError, "Invalid as: #{@as}. Must be one of: #{AS.join(", ")}"
      end
    end
  end
end
