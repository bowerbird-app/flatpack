# frozen_string_literal: true

module FlatPack
  module FloatingFrame
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes as string literals.
      # DO NOT REMOVE:
      # "fp-floating-frame" "fp-floating-frame__panel" "fp-floating-frame__bar"
      # "fp-floating-frame__title" "fp-floating-frame__mount"
      # "p-[var(--card-padding-sm)]" "p-[var(--card-padding-md)]" "p-[var(--card-padding-lg)]"

      POSITIONS = FlatPack::Fab::Component::POSITIONS
      SIZES = FlatPack::Fab::Component::SIZES

      # Scripts and same-origin access so a framed page can run. No top navigation.
      # Pass sandbox: to replace this list. "" is the strict sandbox.
      DEFAULT_SANDBOX = "allow-scripts allow-same-origin allow-forms allow-popups"

      def initialize(
        src:,
        title:,
        label:,
        icon: :arrow_top_right_on_square,
        position: :bottom_right,
        size: :md,
        padding: :md,
        background: nil,
        content_class: nil,
        sandbox: DEFAULT_SANDBOX,
        allow: nil,
        allowfullscreen: false,
        referrerpolicy: "strict-origin-when-cross-origin",
        loading: "lazy",
        **system_arguments
      )
        super(**system_arguments)
        @src = src
        @title = title
        @label = label
        @icon = icon
        @position = position.to_sym
        @size = size.to_sym
        @padding = padding.to_sym
        @background = background
        @content_class = content_class
        @sandbox = sandbox.nil? ? DEFAULT_SANDBOX : sandbox
        @allow = allow
        @allowfullscreen = allowfullscreen
        @referrerpolicy = referrerpolicy
        @loading = loading
        assign_ids!

        validate_label!
        validate_position!
        validate_size!
        validate_padding!
        validate_background!
        validate_content_class!
        validate_embed!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([render_launcher, render_panel])
        end
      end

      private

      def assign_ids!
        given = html_attributes[:id].presence || html_attributes["id"].presence
        @root_id = given || "fp-floating-frame-#{SecureRandom.hex(4)}"
        @trigger_id = "#{@root_id}-trigger"
        @panel_id = "#{@root_id}-panel"
        @title_id = "#{@root_id}-title"
      end

      def root_attributes
        normalize_style_key!
        attrs = {
          id: @root_id,
          class: "fp-floating-frame",
          data: {controller: "flat-pack--floating-frame"}
        }
        style = background_style
        attrs[:style] = style if style
        merge_attributes(**attrs)
      end

      # A string "style" key would survive next to :style and drop one of them.
      def normalize_style_key!
        return unless @system_arguments.key?("style")

        string_style = @system_arguments.delete("style")
        merged = join_styles(@system_arguments[:style], string_style)
        if merged.present?
          @system_arguments[:style] = merged
        else
          @system_arguments.delete(:style)
        end
      end

      def background_style
        return if @background.nil?

        join_styles("--floating-frame-background: #{@background}", html_attributes[:style].presence)
      end

      def render_launcher
        render FlatPack::Fab::Component.new(
          icon: @icon,
          label: @label,
          position: @position,
          size: @size,
          id: @trigger_id,
          aria: {
            expanded: "false",
            controls: @panel_id,
            haspopup: "dialog"
          },
          data: {flat_pack__floating_frame_target: "trigger"}
        )
      end

      def render_panel
        render FlatPack::Popover::Component.new(
          trigger_id: @trigger_id,
          id: @panel_id,
          placement: panel_placement,
          class: "fp-floating-frame__panel",
          role: "dialog",
          aria: {labelledby: @title_id},
          data: {flat_pack__floating_frame_target: "panel"}
        ) do |popover|
          popover.popover_content do
            safe_join([render_bar, render_embed_template, render_mount])
          end
        end
      end

      def render_bar
        content_tag(:div, class: "fp-floating-frame__bar") do
          safe_join([
            content_tag(:h2, @title, id: @title_id, class: "fp-floating-frame__title"),
            render_close_button
          ])
        end
      end

      def render_close_button
        render FlatPack::Button::Component.new(
          text: fp_t("floating_frame.close"),
          icon: "x-mark",
          icon_only: true,
          style: :ghost,
          size: :md,
          type: "button",
          aria: {label: fp_t("floating_frame.close")},
          data: {
            action: "click->flat-pack--floating-frame#prepareRestore flat-pack--popover#close",
            flat_pack__floating_frame_target: "close"
          }
        )
      end

      def render_embed_template
        content_tag(:template, data: {flat_pack__floating_frame_target: "source"}) do
          render FlatPack::Embed::Component.new(**embed_options)
        end
      end

      def render_mount
        content_tag(
          :div,
          "",
          class: mount_classes,
          data: {flat_pack__floating_frame_target: "mount"}
        )
      end

      def mount_classes
        ["fp-floating-frame__mount", padding_class, @content_class].compact_blank.join(" ")
      end

      def padding_class
        FlatPack::Card::Component::PADDINGS.fetch(@padding)
      end

      def embed_options
        {
          src: @src,
          title: @title,
          sandbox: @sandbox,
          allow: @allow,
          allowfullscreen: @allowfullscreen,
          referrerpolicy: @referrerpolicy,
          loading: @loading
        }
      end

      def panel_placement
        (@position == :top_left || @position == :top_right) ? :bottom : :top
      end

      def validate_label!
        unless @label.is_a?(String)
          raise ArgumentError, "label must be a String"
        end

        return if @label.strip.present?

        raise ArgumentError, "label is required"
      end

      def validate_position!
        return if POSITIONS.include?(@position)

        raise ArgumentError, "Invalid position: #{@position}. Must be one of: #{POSITIONS.join(", ")}"
      end

      def validate_size!
        return if SIZES.include?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.join(", ")}"
      end

      def validate_padding!
        return if FlatPack::Card::Component::PADDINGS.key?(@padding)

        keys = FlatPack::Card::Component::PADDINGS.keys.join(", ")
        raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{keys}"
      end

      def validate_content_class!
        return if @content_class.nil?
        return if @content_class.is_a?(String)

        raise ArgumentError, "content_class must be a String."
      end

      def validate_background!
        return if @background.nil?

        sanitized = FlatPack::AttributeSanitizer.sanitize_css_color(@background)
        if sanitized.nil?
          raise ArgumentError, "Invalid background: #{@background}. Pass a CSS color."
        end

        @background = sanitized
      end

      def validate_embed!
        FlatPack::Embed::Component.new(**embed_options)
      end
    end
  end
end
