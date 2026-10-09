# frozen_string_literal: true

module FlatPack
  module Modal
    class Component < FlatPack::BaseComponent
      renders_one :header
      renders_one :body
      renders_one :footer

      undef_method :with_header, :with_header_content
      undef_method :with_body, :with_body_content
      undef_method :with_footer, :with_footer_content

      def header(*args, **kwargs, &block)
        return get_slot(:header) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:header, nil, *args, **kwargs, &block)
      end

      def body(*args, **kwargs, &block)
        return get_slot(:body) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:body, nil, *args, **kwargs, &block)
      end

      def footer(*args, **kwargs, &block)
        return get_slot(:footer) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:footer, nil, *args, **kwargs, &block)
      end

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "max-w-sm" "max-w-xl" "max-w-2xl" "max-w-4xl" "max-w-6xl"
      # "sm:my-auto"
      SIZES = {
        sm: "max-w-sm",
        md: "max-w-xl",
        lg: "max-w-2xl",
        xl: "max-w-4xl",
        "2xl": "max-w-6xl"
      }.freeze

      BODY_HEIGHT_MODES = %i[auto fixed min].freeze
      SCROLL_MODES = %i[body page].freeze
      ORIGINS = %i[center trigger].freeze

      def self.screen_frame_id(modal_id)
        "#{modal_id}-screen"
      end

      def initialize(
        id:,
        title: nil,
        size: :md,
        scroll: :body,
        sticky_footer: false,
        body_height_mode: :auto,
        body_height: nil,
        close_on_backdrop: true,
        close_on_escape: true,
        navigable: false,
        src: nil,
        origin: :center,
        **system_arguments
      )
        super(**system_arguments)
        @modal_id = id
        @title = title
        @size = size.to_sym
        @scroll = scroll.to_sym
        @sticky_footer = sticky_footer
        @body_height_mode = body_height_mode.to_sym
        @body_height = body_height
        @close_on_backdrop = close_on_backdrop
        @close_on_escape = close_on_escape
        @navigable = navigable
        @src = src
        @origin = (origin || :center).to_sym

        validate_id!
        validate_size!
        validate_scroll!
        validate_sticky_footer!
        validate_body_height_mode!
        validate_body_height!
        validate_navigable!
        validate_src!
        validate_origin!
      end

      def call
        validate_navigable_slots! if navigable?

        content_tag(:div, **backdrop_attributes) do
          render_dialog
        end
      end

      private

      def page_scroll?
        @scroll == :page
      end

      def navigable?
        @navigable == true
      end

      def trigger_origin?
        @origin == :trigger
      end

      def sticky_footer?
        page_scroll? && @sticky_footer && (footer? || navigable?)
      end

      def backdrop_attributes
        merge_attributes(
          id: @modal_id,
          class: backdrop_classes,
          data: backdrop_data_attributes,
          aria: {
            hidden: "true"
          }
        )
      end

      def backdrop_data_attributes
        data = {
          controller: controller_attribute,
          "flat-pack--modal-close-on-backdrop-value": @close_on_backdrop,
          "flat-pack--modal-close-on-escape-value": @close_on_escape,
          fp_modal_scroll: @scroll,
          action: action_attributes
        }
        data["flat-pack--navigable-src-value"] = @src if navigable?
        data["flat-pack--modal-origin-value"] = "trigger" if trigger_origin?
        data
      end

      def controller_attribute
        return "flat-pack--modal flat-pack--navigable" if navigable?

        "flat-pack--modal"
      end

      def action_attributes
        actions = ["keydown.tab->flat-pack--modal#handleKeydown"]
        actions << "keydown.esc->flat-pack--modal#close" if @close_on_escape
        actions.concat(navigable_actions) if navigable?
        actions.join(" ")
      end

      def navigable_actions
        [
          "click->flat-pack--navigable#onClick",
          "submit->flat-pack--navigable#onSubmit",
          "turbo:before-fetch-request@document->flat-pack--navigable#onBeforeFetchRequest",
          "turbo:before-fetch-response@document->flat-pack--navigable#onBeforeFetchResponse",
          "turbo:frame-load@document->flat-pack--navigable#onFrameLoad",
          "turbo:frame-missing@document->flat-pack--navigable#onFrameMissing",
          "turbo:fetch-request-error@document->flat-pack--navigable#onFetchError"
        ]
      end

      def backdrop_classes
        classes(
          "fixed",
          "inset-0",
          "z-50",
          "hidden",
          "overflow-y-auto",
          "bg-[var(--modal-backdrop-color)]",
          "backdrop-blur-[var(--modal-backdrop-blur)]",
          "transition-opacity",
          "duration-[var(--duration-slow)]",
          "ease-[var(--easing-enter)]"
        )
      end

      def render_click_backdrop
        # Sits inside the growing wrapper so margin clicks still close after the overlay scrolls.
        content_tag(:div,
          nil,
          class: "absolute inset-0 pointer-events-auto",
          data: {action: "click->flat-pack--modal#clickBackdrop"})
      end

      def render_dialog
        content_tag(:div, class: dialog_wrapper_classes) do
          safe_join([
            render_click_backdrop,
            content_tag(:div, **dialog_attributes) do
              safe_join([
                render_live_region,
                render_header_section || render_close_button_row,
                render_body_content,
                render_footer_content
              ].compact)
            end
          ])
        end
      end

      def dialog_wrapper_classes
        classes(
          "relative flex w-full fp-modal-overlay-min justify-center fp-overlay-pad pointer-events-none",
          page_scroll? ? "items-start" : "items-start sm:items-center"
        )
      end

      def dialog_attributes
        attributes = {
          role: "dialog",
          aria: {
            modal: "true"
          },
          class: dialog_classes,
          data: {
            "flat-pack--modal-target": "dialog"
          },
          tabindex: -1
        }

        attributes[:aria][:labelledby] = header_id if header_section?
        attributes
      end

      def dialog_classes
        classes(
          "pointer-events-auto",
          "relative",
          "flex",
          "flex-col",
          page_scroll? ? nil : "min-h-0",
          page_scroll? ? nil : "fp-modal-dialog-cap",
          "w-full",
          page_scroll? ? nil : "overflow-hidden",
          sticky_footer? ? "fp-modal-page-sticky" : nil,
          page_scroll? ? "sm:my-auto" : nil,
          size_classes,
          "p-4",
          "sm:p-6",
          "bg-[var(--modal-surface-color)]",
          "rounded-[var(--radius-lg)]",
          "shadow-lg",
          "border",
          "border-[var(--modal-border-color)]",
          "transition-[opacity,scale]",
          "duration-[var(--duration-slow)]",
          "ease-[var(--easing-enter)]",
          "scale-95",
          "motion-reduce:scale-100",
          "opacity-0"
        )
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def render_close_button
        content_tag(:button,
          type: "button",
          class: close_button_classes,
          aria: {label: fp_t("modal.close")},
          data: {action: "flat-pack--modal#close"}) do
          close_icon
        end
      end

      def close_button_classes
        "shrink-0 cursor-pointer text-[var(--modal-close-icon-color)] hover:text-[var(--modal-close-icon-hover-color)] transition-colors rounded-[var(--radius-sm)] p-1 fp-hit-target focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring"
      end

      def render_header_section
        return nil unless header_section?

        content_tag(:div, class: header_wrapper_classes) do
          if navigable?
            safe_join([
              render_back_button,
              render_header_content,
              render_header_actions,
              render_close_button
            ])
          else
            safe_join([
              render_header_content,
              render_close_button
            ])
          end
        end
      end

      def render_back_button
        content_tag(:button,
          type: "button",
          class: close_button_classes,
          hidden: true,
          disabled: true,
          aria: {label: fp_t("modal.back"), hidden: true},
          data: {
            "flat-pack--navigable-target": "backButton",
            fp_nav: "back"
          }) do
          render FlatPack::Shared::IconComponent.new(name: "arrow-left", size: :md)
        end
      end

      def render_header_actions
        content_tag(:div, nil, class: "min-w-0 flex items-center gap-2", data: {"flat-pack--navigable-target": "headerActions"})
      end

      def render_live_region
        return unless navigable?

        content_tag(:div, "", class: "sr-only", aria: {live: "polite", atomic: true}, data: {"flat-pack--navigable-target": "liveRegion"})
      end

      def render_close_button_row
        content_tag(:div, class: close_button_row_classes) { render_close_button }
      end

      def close_icon
        render FlatPack::Shared::IconComponent.new(name: "x-mark", size: :md)
      end

      def render_header_content
        return nil unless @title || header? || navigable?

        content_tag(:div, id: header_id, class: header_classes) do
          if header? && !navigable?
            # SECURITY: Slot content is marked html_safe because it's expected to contain
            # Rails-generated HTML from other components. Never pass unsanitized user input
            # directly to this slot.
            header.to_s.html_safe
          else
            content_tag(:h2, @title, **title_heading_attributes)
          end
        end
      end

      def title_heading_attributes
        attributes = {
          class: "text-lg font-semibold text-[var(--modal-title-color)] fp-text-balance"
        }
        return attributes unless navigable?

        attributes[:tabindex] = -1
        attributes[:data] = {"flat-pack--navigable-target": "title"}
        attributes
      end

      def render_body_content
        if navigable?
          content_tag(:div, **body_attributes) do
            safe_join([
              render_navigable_frame,
              render_navigable_loading,
              render_navigable_error
            ])
          end
        else
          return nil unless body?

          # SECURITY: Slot content is marked html_safe because it's expected to contain
          # Rails-generated HTML from other components. Never pass unsanitized user input
          # directly to this slot.
          content_tag(:div, body.to_s.html_safe, **body_attributes)
        end
      end

      def body_attributes
        attributes = {
          class: body_classes
        }

        height_style = body_style
        attributes[:style] = height_style if height_style.present?
        attributes
      end

      def render_footer_content
        if navigable?
          content_tag(:div, footer? ? footer.to_s.html_safe : nil, class: footer_classes, hidden: !footer?, data: {"flat-pack--navigable-target": "footer"})
        else
          return nil unless footer?

          # SECURITY: Slot content is marked html_safe because it's expected to contain
          # Rails-generated HTML from other components. Never pass unsanitized user input
          # directly to this slot.
          content_tag(:div, footer.to_s.html_safe, class: footer_classes)
        end
      end

      def render_navigable_frame
        content_tag(:"turbo-frame", **navigable_frame_attributes) do
          render_navigable_frame_placeholder
        end
      end

      def navigable_frame_attributes
        {
          id: self.class.screen_frame_id(@modal_id),
          src: @src,
          loading: "lazy",
          class: "block min-h-48",
          data: {"flat-pack--navigable-target": "frame"}
        }
      end

      def render_navigable_frame_placeholder
        content_tag(:div, class: "flex flex-col items-center justify-center gap-3 py-12") do
          safe_join([
            render(FlatPack::Spinner::Component.new(size: :lg)),
            render(FlatPack::Skeleton::Component.new(variant: :title, class: "max-w-xs")),
            render(FlatPack::Skeleton::Component.new(variant: :text, class: "max-w-sm"))
          ])
        end
      end

      def render_navigable_loading
        content_tag(:div,
          class: "absolute inset-0 z-10 flex flex-col items-center justify-center gap-3 bg-[var(--modal-surface-color)]",
          hidden: true,
          data: {"flat-pack--navigable-target": "loading"}) do
          safe_join([
            render(FlatPack::Spinner::Component.new(size: :lg, label: fp_t("modal.loading"))),
            render(FlatPack::Skeleton::Component.new(variant: :title, class: "max-w-xs")),
            render(FlatPack::Skeleton::Component.new(variant: :text, class: "max-w-sm"))
          ])
        end
      end

      def render_navigable_error
        content_tag(:div,
          class: "absolute inset-0 z-10 flex items-center justify-center bg-[var(--modal-surface-color)] p-4",
          hidden: true,
          data: {"flat-pack--navigable-target": "error"}) do
          render FlatPack::EmptyState::Component.new(
            title: fp_t("modal.load_error"),
            description: fp_t("modal.load_error_hint"),
            icon: :exclamation_circle,
            size: :sm
          ) do |empty|
            empty.slot do
              render FlatPack::Button::Component.new(
                text: fp_t("modal.retry"),
                style: :primary,
                data: {fp_nav: "retry"}
              )
            end
          end
        end
      end

      def header_section?
        return true if navigable?

        @title.present? || header?
      end

      def header_wrapper_classes
        if navigable?
          classes(
            "flat-pack-modal__header shrink-0 flex items-center justify-between gap-3",
            sticky_footer? ? "fp-modal-sticky-header" : nil
          )
        else
          classes(
            "flat-pack-modal__header shrink-0 flex items-start justify-between gap-3",
            sticky_footer? ? "fp-modal-sticky-header" : nil
          )
        end
      end

      def close_button_row_classes
        classes(
          "flat-pack-modal__close",
          "shrink-0",
          "flex",
          "justify-end",
          (header_section? ? nil : "pb-2")
        )
      end

      def header_classes
        navigable? ? "min-w-0 flex-1" : "min-w-0"
      end

      def body_classes
        if navigable?
          classes(
            "flat-pack-modal__body",
            "min-h-0",
            "relative",
            body_layout_class,
            body_overflow_class,
            "pt-4",
            "text-sm",
            "text-[var(--modal-body-color)]"
          )
        else
          classes(
            "flat-pack-modal__body",
            "min-h-0",
            body_layout_class,
            body_overflow_class,
            "pt-4",
            "text-sm",
            "text-[var(--modal-body-color)]"
          )
        end
      end

      def body_layout_class
        (@body_height_mode == :auto) ? "flex-1" : "shrink-0"
      end

      def body_overflow_class
        return "overflow-y-auto" unless page_scroll?
        return "overflow-y-auto" if @body_height_mode == :fixed

        nil
      end

      def body_style
        return nil unless @body_height_mode != :auto

        case @body_height_mode
        when :fixed
          "--flatpack-modal-body-height: #{@body_height}; height: var(--flatpack-modal-body-height);"
        when :min
          "--flatpack-modal-body-height: #{@body_height}; min-height: var(--flatpack-modal-body-height);"
        end
      end

      def footer_classes
        classes(
          "flat-pack-modal__footer shrink-0 pt-4 flex justify-end gap-3",
          sticky_footer? ? "fp-modal-sticky-footer" : nil
        )
      end

      def header_id
        "#{@modal_id}-title"
      end

      def validate_id!
        return if @modal_id.present?
        raise ArgumentError, "id is required"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_scroll!
        return if SCROLL_MODES.include?(@scroll)

        raise ArgumentError, "Invalid scroll: #{@scroll}. Must be one of: #{SCROLL_MODES.join(", ")}"
      end

      def validate_sticky_footer!
        unless [true, false].include?(@sticky_footer)
          raise ArgumentError, "sticky_footer must be true or false"
        end

        return unless @sticky_footer
        return if page_scroll?

        raise ArgumentError, "sticky_footer requires scroll: :page"
      end

      def validate_body_height_mode!
        return if BODY_HEIGHT_MODES.include?(@body_height_mode)

        raise ArgumentError, "Invalid body_height_mode: #{@body_height_mode}. Must be one of: #{BODY_HEIGHT_MODES.join(", ")}"
      end

      def validate_body_height!
        return if @body_height_mode == :auto
        return if @body_height.present? && @body_height.match?(/\A[0-9a-zA-Z\s\-+*%.,()\[\]_]+\z/)

        raise ArgumentError, "body_height is required for non-auto body_height_mode and may only contain CSS length/expression characters"
      end

      def validate_origin!
        return if ORIGINS.include?(@origin)

        raise ArgumentError, "Invalid origin: #{@origin}. Must be one of: #{ORIGINS.join(", ")}"
      end

      def validate_navigable!
        unless [true, false].include?(@navigable)
          raise ArgumentError, "navigable must be true or false"
        end
      end

      def validate_src!
        if navigable?
          if @src.blank?
            raise ArgumentError, "src is required when navigable: true"
          end

          sanitized = FlatPack::AttributeSanitizer.sanitize_url(@src)
          if sanitized.blank?
            raise ArgumentError, "Unsafe src. Only http, https, and relative URLs are allowed."
          end

          @src = sanitized
          return
        end

        return if @src.nil?

        raise ArgumentError, "src is only valid when navigable: true"
      end

      def validate_navigable_slots!
        if body?
          raise ArgumentError, "body slot is not used when navigable: true; put screen content in src"
        end
        return unless header?

        raise ArgumentError, "header slot is not used when navigable: true; screens supply the title"
      end
    end
  end
end
