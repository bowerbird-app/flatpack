# frozen_string_literal: true

module FlatPack
  # Maps a list of page actions and a placement context to rendered buttons.
  # This is the only place a role becomes a button style.
  module PageActions
    CONTEXTS = %i[header top_nav mobile].freeze

    # Concrete Button `style:` tokens. A layout overrides a role with `styles:`.
    STYLES = {
      header: {primary: :primary, secondary: :secondary, destructive: :danger}.freeze,
      top_nav: {primary: :secondary, secondary: :ghost, destructive: :danger}.freeze,
      mobile: {primary: :primary, secondary: :secondary, destructive: :danger}.freeze
    }.freeze

    SIZES = {
      header: :sm,
      top_nav: :sm,
      mobile: :md
    }.freeze

    class << self
      def styles(context, overrides = nil)
        name = normalize_context!(context)
        map = STYLES.fetch(name).dup
        apply_overrides!(map, overrides)
        map
      end

      def render(view, actions, context, styles: nil)
        list = Array(actions)
        return if list.empty?

        name = normalize_context!(context)
        map = styles(name, styles)
        if name == :mobile
          render_mobile(view, list, map)
        else
          render_group(view, list, map, SIZES.fetch(name))
        end
      end

      private

      def normalize_context!(context)
        name = context.to_sym
        return name if CONTEXTS.include?(name)

        raise ArgumentError, "context must be :header, :top_nav, or :mobile"
      end

      def apply_overrides!(map, overrides)
        return map if overrides.blank?

        overrides.each do |role, style|
          role_name = role.to_sym
          unless PageAction::ROLES.include?(role_name)
            raise ArgumentError, "role must be :primary, :secondary, or :destructive"
          end

          style_name = style.to_sym
          unless Button::StyleRegistry.known?(style_name)
            raise ArgumentError, Button::StyleRegistry.invalid_style_message(style_name)
          end

          map[role_name] = style_name
        end

        map
      end

      def render_group(view, actions, map, size)
        view.render(FlatPack::ButtonGroup::Component.new) do |group|
          actions.each do |action|
            group.button(button_for(action, map, size))
          end
        end
      end

      def render_mobile(view, actions, map)
        first, *rest = actions
        parts = [view.render(button_for(first, map, SIZES.fetch(:mobile)))]
        parts << render_overflow(view, rest) if rest.any?
        view.safe_join(parts)
      end

      def render_overflow(view, actions)
        view.render(FlatPack::Button::Dropdown::Component.new(
          text: FlatPack::Copy.t("page_actions.more"),
          icon: "ellipsis-horizontal",
          icon_only: true,
          style: :ghost,
          size: :md
        )) do |dropdown|
          actions.each do |action|
            dropdown.menu_item(**menu_item_arguments(action))
          end
        end
      end

      def button_for(action, map, size)
        arguments = {
          text: action.label,
          href: action.href,
          style: map.fetch(action.role),
          size: size
        }
        arguments[:icon] = action.icon if action.icon.present?
        arguments[:data] = action.data if action.data
        arguments[:aria] = action.aria if action.aria
        FlatPack::Button::Component.new(**arguments)
      end

      def menu_item_arguments(action)
        arguments = {
          text: action.label,
          href: action.href,
          destructive: action.role == :destructive
        }
        arguments[:icon] = action.icon if action.icon.present?
        arguments[:data] = action.data if action.data
        arguments[:aria] = action.aria if action.aria
        arguments
      end
    end
  end
end
