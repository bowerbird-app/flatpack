# frozen_string_literal: true

module FlatPack
  module ContentEditor
    class Component < FlatPack::BaseComponent
      include FlatPack::Shared::ExecCommandBalloon

      ICON_BOLD = FlatPack::Shared::ExecCommandBalloon::ICON_BOLD
      ICON_ITALIC = FlatPack::Shared::ExecCommandBalloon::ICON_ITALIC
      ICON_UNDERLINE = FlatPack::Shared::ExecCommandBalloon::ICON_UNDERLINE
      ICON_STRIKE = FlatPack::Shared::ExecCommandBalloon::ICON_STRIKE
      ICON_CLEAR = FlatPack::Shared::ExecCommandBalloon::ICON_CLEAR
      ICON_UL = FlatPack::Shared::ExecCommandBalloon::ICON_UL
      ICON_OL = FlatPack::Shared::ExecCommandBalloon::ICON_OL
      ICON_BLOCKQUOTE = FlatPack::Shared::ExecCommandBalloon::ICON_BLOCKQUOTE
      ICON_LINK = FlatPack::Shared::ExecCommandBalloon::ICON_LINK
      ICON_IMAGE = FlatPack::Shared::ExecCommandBalloon::ICON_IMAGE

      def initialize(
        update_url:,
        upload_url: nil,
        toolbar: true,
        content_class: nil,
        field_name: "body",
        field_format_name: "body_format",
        field_format: "html",
        **system_arguments
      )
        super(**system_arguments)
        @update_url = update_url
        @upload_url = upload_url
        @toolbar = toolbar
        @content_class = content_class
        @field_name = field_name
        @field_format_name = field_format_name
        @field_format = field_format
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_actions,
            (@toolbar ? render_balloon_toolbar : nil),
            render_content_region
          ].compact)
        end
      end

      private

      def wrapper_attributes
        attrs = {
          data: {
            controller: "flat-pack--content-editor",
            flat_pack__content_editor_update_url_value: @update_url,
            flat_pack__content_editor_field_name_value: @field_name,
            flat_pack__content_editor_field_format_name_value: @field_format_name,
            flat_pack__content_editor_field_format_value: @field_format
          },
          class: "flat-pack-content-editor"
        }
        attrs[:data][:flat_pack__content_editor_upload_url_value] = @upload_url if @upload_url
        attrs
      end

      def render_actions
        content_tag(:div, class: "flat-pack-content-editor-actions") do
          safe_join([
            render_edit_button,
            render_save_button,
            render_cancel_button
          ])
        end
      end

      def render_edit_button
        content_tag(
          :button,
          fp_t("content_editor.edit"),
          type: "button",
          class: "flat-pack-btn flat-pack-btn--primary",
          data: {
            flat_pack__content_editor_target: "editBtn",
            action: "flat-pack--content-editor#enableEditing"
          }
        )
      end

      def render_save_button
        content_tag(
          :button,
          fp_t("content_editor.save"),
          type: "button",
          hidden: true,
          class: "flat-pack-btn flat-pack-btn--primary",
          data: {
            flat_pack__content_editor_target: "saveBtn",
            action: "flat-pack--content-editor#save"
          }
        )
      end

      def render_cancel_button
        content_tag(
          :button,
          fp_t("content_editor.cancel"),
          type: "button",
          hidden: true,
          class: "flat-pack-btn flat-pack-btn--secondary",
          data: {
            flat_pack__content_editor_target: "cancelBtn",
            action: "flat-pack--content-editor#cancel"
          }
        )
      end

      def render_balloon_toolbar
        render_exec_command_balloon(
          controller: "flat-pack--content-editor",
          target: "balloonToolbar",
          upload_url: @upload_url
        )
      end

      def render_content_region
        content_tag(
          :div,
          content,
          class: ["flat-pack-content-editor-content", @content_class].compact.join(" "),
          data: {flat_pack__content_editor_target: "displayContent"}
        )
      end
    end
  end
end
