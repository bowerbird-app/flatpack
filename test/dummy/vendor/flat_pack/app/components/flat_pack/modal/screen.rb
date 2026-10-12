# frozen_string_literal: true

module FlatPack
  module Modal
    # Wraps a Turbo Frame response for a navigable modal (or, later, drawer).
    # Title, header actions, and footer are read by `flat-pack--navigable`.
    class Screen < FlatPack::BaseComponent
      renders_one :header_actions
      renders_one :footer

      undef_method :with_header_actions, :with_header_actions_content
      undef_method :with_footer, :with_footer_content

      def header_actions(*args, **kwargs, &block)
        return get_slot(:header_actions) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:header_actions, nil, *args, **kwargs, &block)
      end

      def footer(*args, **kwargs, &block)
        return get_slot(:footer) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:footer, nil, *args, **kwargs, &block)
      end

      def self.catalog_description
        "Screen wrapper for a navigable modal: matching turbo-frame, title, and optional header/footer slots."
      end

      def initialize(modal_id:, title:, **system_arguments)
        super(**system_arguments)
        @modal_id = modal_id
        @title = title

        validate_modal_id!
        validate_title!
      end

      def call
        content_tag(:"turbo-frame", id: frame_id) do
          content_tag(:div, **screen_attributes) do
            safe_join([
              render_header_actions,
              content,
              render_footer
            ].compact)
          end
        end
      end

      private

      def frame_id
        FlatPack::Modal::Component.screen_frame_id(@modal_id)
      end

      def screen_attributes
        merge_attributes(
          data: {
            fp_screen: true,
            title: @title
          }
        )
      end

      def render_header_actions
        return unless header_actions?

        content_tag(:div, header_actions.to_s.html_safe, data: {"fp-screen-header-actions": true})
      end

      def render_footer
        return unless footer?

        content_tag(:div, footer.to_s.html_safe, data: {"fp-screen-footer": true})
      end

      def validate_modal_id!
        return if @modal_id.present?

        raise ArgumentError, "modal_id is required"
      end

      def validate_title!
        return if @title.present?

        raise ArgumentError, "title is required"
      end
    end
  end
end
