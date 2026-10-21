# frozen_string_literal: true

module FlatPack
  module SegmentedButtons
    class Component < FlatPack::BaseComponent
      SIZES = FlatPack::Button::Component::SIZES
      STYLES = FlatPack::Button::StyleRegistry::BUILT_IN
      UNSELECTED_STYLE = :secondary

      renders_many :buttons, lambda { |text:, selected: false, size: nil, **args|
        if args.key?(:style)
          raise ArgumentError, "Pass style: to SegmentedButtons, not to a segment."
        end

        if sliding_indicator?
          slide_button(text: text, selected: selected, size: size, **args)
        else
          style = selected ? (@style || UNSELECTED_STYLE) : UNSELECTED_STYLE
          FlatPack::Button::Component.new(
            text: text,
            style: style,
            current: selected && @style.nil?,
            size: size.nil? ? @size : size,
            **args
          )
        end
      }

      undef_method :with_button, :with_button_content

      def initialize(size: :md, style: nil, indicator: nil, **system_arguments)
        super(**system_arguments)
        @size = size.to_sym
        @style = style&.to_sym
        @indicator = FlatPack::Shared::SlideIndicator.normalize(indicator)
        validate_size!
        validate_style!
      end

      def button(*args, **kwargs, &block)
        set_slot(:buttons, nil, *args, **kwargs, &block)
      end

      def call
        content_tag(:div, **group_attributes) do
          safe_join(slide_nodes + buttons.map(&:call))
        end
      end

      private

      def slide_nodes
        return [] unless sliding_indicator?

        [render_slide_indicator]
      end

      def render_slide_indicator
        content_tag(
          :span,
          "",
          class: FlatPack::Shared::SlideIndicator.indicator_classes(kind: FlatPack::Shared::SlideIndicator::KIND_PILL),
          aria: {hidden: true},
          data: {"flat-pack--slide-indicator-target": "indicator"}
        )
      end

      def group_attributes
        return merge_attributes(class: group_classes) unless sliding_indicator?

        pill = pill_style
        slide_data = FlatPack::Shared::SlideIndicator.list_data(kind: FlatPack::Shared::SlideIndicator::KIND_PILL)
        slide_data[:fp_style] = pill.data_fp_style if pill.data_fp_style

        {
          class: classes(
            "#{FlatPack::Button::Pill::Component::GROUP_CLASSES} #{pill.group_class} #{FlatPack::Shared::SlideIndicator::LIST_CLASS}"
          ),
          data: merge_data_attributes(data_attributes, slide_data),
          aria: aria_attributes
        }.merge(html_attributes).compact
      end

      def slide_button(text:, selected:, size:, **args)
        caller_aria = args.delete(:aria) || {}
        caller_data = args.delete(:data) || {}
        caller_class = args.delete(:class)
        text_classes = selected ? FlatPack::Button::PillStyle::ACTIVE_TEXT_CLASSES : FlatPack::Button::PillStyle::INACTIVE_TEXT_CLASSES

        FlatPack::Button::Component.new(
          text: text,
          style: UNSELECTED_STYLE,
          current: false,
          size: size.nil? ? @size : size,
          class: [caller_class, FlatPack::Shared::SlideIndicator::ITEM_CLASS, "rounded-[var(--tabs-pill-corner-radius)]", text_classes].compact.join(" "),
          aria: caller_aria.merge(pressed: selected ? "true" : "false"),
          data: merge_data_attributes(caller_data, slide_item_data),
          **args
        )
      end

      def slide_item_data
        FlatPack::Shared::SlideIndicator.item_data.merge(
          "flat-pack-slide-indicator-active-classes": FlatPack::Button::PillStyle::ACTIVE_TEXT_CLASSES,
          "flat-pack-slide-indicator-inactive-classes": FlatPack::Button::PillStyle::INACTIVE_TEXT_CLASSES
        )
      end

      def pill_style
        FlatPack::Button::PillStyle.resolve(@style)
      end

      def sliding_indicator?
        @indicator == :slide
      end

      def group_classes
        classes(
          "inline-flex",
          "rounded-[var(--button-border-radius)]",
          "shadow-sm",
          "[&>*]:rounded-none",
          "[&>*:first-child]:rounded-l-[var(--button-border-radius)]",
          "[&>*:last-child]:rounded-r-[var(--button-border-radius)]",
          "[&>*]:border-r-0",
          "[&>*:last-child]:border-r",
          "[&>*]:shadow-none"
        )
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_style!
        return if @style.nil?
        return if FlatPack::Button::StyleRegistry.known?(@style)

        raise ArgumentError, FlatPack::Button::StyleRegistry.invalid_style_message(@style)
      end
    end
  end
end
