# frozen_string_literal: true

module FlatPack
  module Clipboard
    # Idle, copied, and error glyphs sit together. The clipboard controller
    # toggles `hidden` on data-flat-pack-clipboard-icon. CopyButton uses CSS
    # and does not render these markers.
    module StateIcons
      private

      def render_clipboard_state_icons(idle_name, size:, **icon_arguments)
        safe_join([
          render_clipboard_state_icon("idle", idle_name, size, hidden: false, **icon_arguments),
          render_clipboard_state_icon("copied", "check", size, hidden: true, **icon_arguments),
          render_clipboard_state_icon("error", "exclamation-circle", size, hidden: true, **icon_arguments)
        ])
      end

      def render_clipboard_state_icon(state, name, size, hidden:, **icon_arguments)
        css = [icon_arguments[:class], ("hidden" if hidden)].compact.join(" ")
        render FlatPack::Shared::IconComponent.new(
          **icon_arguments.except(:class),
          name: name,
          size: size,
          class: css.presence,
          data: {flat_pack_clipboard_icon: state}
        )
      end
    end
  end
end
