# frozen_string_literal: true

module FlatPack
  module PageNav
    class Component < FlatPack::BaseComponent
      BackPlan = Data.define(:mode, :href) do
        def hidden?
          mode == :hidden
        end

        def link?
          mode == :link
        end

        def history?
          mode == :history
        end
      end
      private_constant :BackPlan

      # Icon link in the middle of the row. The tooltip is the accessible name.
      class Link < FlatPack::BaseComponent
        def initialize(href:, icon:, tooltip:, style:, size:, round:)
          super()
          @href = href
          @icon = icon
          @tooltip = tooltip
          @style = style
          @size = size
          @round = round

          raise ArgumentError, "Page nav link needs an href." if @href.blank?
          raise ArgumentError, "Page nav link needs an icon." if @icon.blank?
          raise ArgumentError, "Page nav link needs a tooltip." if @tooltip.blank?
        end

        def call
          button = render(FlatPack::Button::Component.new(
            icon: @icon,
            icon_only: true,
            style: @style,
            size: @size,
            round: @round,
            href: @href,
            aria: {label: @tooltip}
          ))

          render(FlatPack::Tooltip::Component.new(text: @tooltip)) { button }
        end
      end
      private_constant :Link

      renders_one :right_slot
      renders_many :links, lambda { |href:, icon:, tooltip:|
        Link.new(
          href: href,
          icon: icon,
          tooltip: tooltip,
          style: @anchor_style,
          size: @anchor_size,
          round: @round
        )
      }

      def initialize(
        back_icon: "chevron-left",
        back_tooltip: nil,
        # Deprecated: Use back_tooltip instead.
        back_label: FlatPack::Copy::OMITTED,
        back_style: :secondary,
        back_size: :md,
        show_back: true,
        back_href: nil,
        round: false,
        anchor_href: nil,
        anchor_icon: "x-mark",
        anchor_tooltip: nil,
        # Deprecated: Use anchor_tooltip instead.
        anchor_label: FlatPack::Copy::OMITTED,
        anchor_style: :secondary,
        anchor_size: :md,
        **system_arguments
      )
        reject_removed_secondary!(system_arguments)
        super(**system_arguments)

        @back_icon = back_icon
        @back_label = back_tooltip.presence || fp_text(back_label, "page_nav.back")
        @back_style = back_style
        @back_size = back_size
        @show_back = show_back
        @back_href = back_href
        @round = round

        @anchor_href = anchor_href
        @anchor_icon = anchor_icon
        @anchor_label = anchor_tooltip.presence || fp_text(anchor_label, "page_nav.close")
        @anchor_style = anchor_style
        @anchor_size = anchor_size

        validate_round!
      end

      def right_slot(*args, **kwargs, &block)
        return get_slot(:right_slot) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:right_slot, nil, *args, **kwargs, &block)
      end

      def right(*args, **kwargs, &block)
        right_slot(*args, **kwargs, &block)
      end

      def right?
        right_slot?
      end

      def call
        content_tag(:nav, **nav_attributes) do
          content_tag(:div, class: "flex gap-2") do
            safe_join([
              left_actions,
              anchor_actions,
              link_actions,
              right_slot_wrapper
            ].compact)
          end
        end
      end

      private

      def nav_attributes
        attributes = {
          class: "flat-pack-page-nav",
          aria: {label: fp_t("page_nav.label")}
        }
        attributes[:data] = history_nav_data if back_plan.history?

        merge_attributes(**attributes)
      end

      def left_actions
        plan = back_plan
        return if plan.hidden?

        content_tag(:div, class: "flex items-center gap-2") do
          back_action(plan)
        end
      end

      def back_action(plan)
        tooltip_wrapper(@back_label) do
          icon_button(
            icon: @back_icon,
            label: @back_label,
            style: @back_style,
            size: @back_size,
            **back_button_arguments(plan)
          )
        end
      end

      def back_button_arguments(plan)
        return {href: plan.href} if plan.link?

        {data: {action: "click->flat-pack--page-nav#back"}}
      end

      def history_nav_data
        data = {controller: "flat-pack--page-nav"}
        data[:flat_pack__page_nav_fallback_url_value] = @anchor_href if @anchor_href.present?
        data
      end

      def back_plan
        @back_plan ||= if !@show_back
          BackPlan.new(:hidden, nil)
        elsif @back_href.present?
          BackPlan.new(:link, @back_href)
        else
          BackPlan.new(:history, nil)
        end
      end

      def anchor_action
        return unless @anchor_href.present?

        tooltip_wrapper(@anchor_label) do
          icon_button(
            icon: @anchor_icon,
            label: @anchor_label,
            style: @anchor_style,
            size: @anchor_size,
            href: @anchor_href
          )
        end
      end

      def anchor_actions
        action = anchor_action
        return if action.nil?

        content_tag(:div, class: "flex items-center gap-2") do
          action
        end
      end

      def link_actions
        return unless links?

        content_tag(:div, class: "flex items-center gap-2") do
          safe_join(links)
        end
      end

      def right_slot_wrapper
        return unless right?

        content_tag(:div, class: "ml-auto flex items-center gap-2") do
          right.to_s
        end
      end

      def tooltip_wrapper(text)
        button = capture { yield }
        return button if text.blank?

        render FlatPack::Tooltip::Component.new(text: text) do
          button
        end
      end

      def icon_button(icon:, label:, style:, size:, href: nil, data: nil)
        button_arguments = {
          icon: icon,
          icon_only: true,
          style: style,
          size: size,
          round: @round,
          aria: {label: label}
        }
        button_arguments[:href] = href if href.present?
        button_arguments[:data] = data if data.present?

        render FlatPack::Button::Component.new(**button_arguments)
      end

      def validate_round!
        return if @round == true || @round == false

        raise ArgumentError, "Invalid round: #{@round.inspect}. Must be true or false."
      end

      def reject_removed_secondary!(arguments)
        removed = arguments.keys.grep(/\Asecondary_anchor/)
        return if removed.empty?

        raise ArgumentError, "unknown keyword: :#{removed.first}"
      end
    end
  end
end
