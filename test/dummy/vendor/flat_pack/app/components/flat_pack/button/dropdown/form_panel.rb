# frozen_string_literal: true

module FlatPack
  module Button
    module Dropdown
      # Form body inside a dropdown menu. Not a menuitem, so other items keep
      # role="menuitem". Clicks inside stay in the open menu.
      class FormPanel < FlatPack::BaseComponent
        def menu_row
          {skip: true}
        end

        def call
          content_tag(:div, content, **panel_attributes)
        end

        private

        def panel_attributes
          merge_attributes(
            class: panel_classes,
            role: "none",
            data: {flat_pack_dropdown_keep_open: true}
          )
        end

        def panel_classes
          classes(
            "fp-button-dropdown__form",
            "px-[var(--dropdown-item-padding-x)] py-[var(--dropdown-item-padding-y)]"
          )
        end
      end
    end
  end
end
