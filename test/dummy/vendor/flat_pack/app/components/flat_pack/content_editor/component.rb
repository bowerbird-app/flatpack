# frozen_string_literal: true

module FlatPack
  module ContentEditor
    class Component < FlatPack::BaseComponent
      # SECURITY: These SVG strings are developer-controlled constants, not user input.
      # They are marked html_safe because they contain intentional SVG markup.
      ICON_BOLD = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M15.6 10.79c.97-.67 1.65-1.77 1.65-2.79 0-2.26-1.75-4-4-4H7v14h7.04c2.09 0 3.71-1.7 3.71-3.79 0-1.52-.86-2.82-2.15-3.42zM10 6.5h3c.83 0 1.5.67 1.5 1.5s-.67 1.5-1.5 1.5h-3v-3zm3.5 9H10v-3h3.5c.83 0 1.5.67 1.5 1.5s-.67 1.5-1.5 1.5z"/></svg>
      SVG
      ICON_ITALIC = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M10 4v3h2.21l-3.42 8H6v3h8v-3h-2.21l3.42-8H18V4z"/></svg>
      SVG
      ICON_UNDERLINE = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M12 17c3.31 0 6-2.69 6-6V3h-2.5v8c0 1.93-1.57 3.5-3.5 3.5S8.5 12.93 8.5 11V3H6v8c0 3.31 2.69 6 6 6zm-7 2v2h14v-2H5z"/></svg>
      SVG
      ICON_STRIKE = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M10 19h4v-3h-4v3zM5 4v3h5v3h4V7h5V4H5zM3 14h18v-2H3v2z"/></svg>
      SVG
      ICON_CLEAR = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M3.27 5L2 6.27l6.97 6.97L6.5 19h3l1.57-3.66L16.73 21 18 19.73 3.55 5.27 3.27 5zM6 5v.18L8.82 8h2.4l-.72 1.68 2.1 2.1L14.21 8H20V5H6z"/></svg>
      SVG
      ICON_UL = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M4 10.5c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5-.67-1.5-1.5-1.5zm0-6c-.83 0-1.5.67-1.5 1.5S3.17 7.5 4 7.5 5.5 6.83 5.5 6 4.83 4.5 4 4.5zm0 12c-.83 0-1.5.68-1.5 1.5s.68 1.5 1.5 1.5 1.5-.68 1.5-1.5-.67-1.5-1.5-1.5zM7 19h14v-2H7v2zm0-6h14v-2H7v2zm0-8v2h14V5H7z"/></svg>
      SVG
      ICON_OL = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M2 17h2v.5H3v1h1v.5H2v1h3v-4H2v1zm1-9h1V4H2v1h1v3zm-1 3h1.8L2 13.1v.9h3v-1H3.2L5 10.9V10H2v1zm5-6v2h14V5H7zm0 14h14v-2H7v2zm0-6h14v-2H7v2z"/></svg>
      SVG
      ICON_BLOCKQUOTE = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M6 17h3l2-4V7H5v6h3zm8 0h3l2-4V7h-6v6h3z"/></svg>
      SVG
      ICON_LINK = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M3.9 12c0-1.71 1.39-3.1 3.1-3.1h4V7H7c-2.76 0-5 2.24-5 5s2.24 5 5 5h4v-1.9H7c-1.71 0-3.1-1.39-3.1-3.1zM8 13h8v-2H8v2zm9-6h-4v1.9h4c1.71 0 3.1 1.39 3.1 3.1s-1.39 3.1-3.1 3.1h-4V17h4c2.76 0 5-2.24 5-5s-2.24-5-5-5z"/></svg>
      SVG
      ICON_IMAGE = <<~SVG.html_safe
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/></svg>
      SVG

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
          "Edit",
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
          "Save",
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
          "Cancel",
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
        content_tag(
          :div,
          style: "position:fixed;z-index:9999;display:none;",
          hidden: true,
          class: "flat-pack-richtext-bubble-menu",
          data: {
            flat_pack__content_editor_target: "balloonToolbar",
            action: "mousedown->flat-pack--content-editor#keepSelection"
          }
        ) do
          safe_join([
            toolbar_btn("bold", "Bold", ICON_BOLD),
            toolbar_btn("italic", "Italic", ICON_ITALIC),
            toolbar_btn("underline", "Underline", ICON_UNDERLINE),
            toolbar_btn("strikeThrough", "Strikethrough", ICON_STRIKE),
            toolbar_btn("removeFormat", "Clear formatting", ICON_CLEAR),
            content_tag(:span, "", class: "flat-pack-richtext-bubble-sep"),
            toolbar_btn("h1", "Heading 1", "H1", style: "font-size:11px;font-weight:700;width:28px;"),
            toolbar_btn("h2", "Heading 2", "H2", style: "font-size:11px;font-weight:700;width:28px;"),
            toolbar_btn("h3", "Heading 3", "H3", style: "font-size:11px;font-weight:700;width:28px;"),
            content_tag(:span, "", class: "flat-pack-richtext-bubble-sep"),
            toolbar_btn("insertUnorderedList", "Bullet list", ICON_UL),
            toolbar_btn("insertOrderedList", "Ordered list", ICON_OL),
            toolbar_btn("blockquote", "Blockquote", ICON_BLOCKQUOTE),
            content_tag(:span, "", class: "flat-pack-richtext-bubble-sep"),
            toolbar_btn("link", "Insert / edit link", ICON_LINK),
            *render_image_upload_controls
          ])
        end
      end

      def toolbar_btn(command, title, inner, style: nil)
        attrs = {
          type: "button",
          title: title,
          class: "flat-pack-richtext-bubble-btn",
          data: {
            action: "flat-pack--content-editor#format",
            command: command
          }
        }
        attrs[:style] = style if style
        content_tag(:button, inner.html_safe, **attrs)
      end

      def render_image_upload_controls
        return [] unless @upload_url

        [
          content_tag(:span, "", class: "flat-pack-richtext-bubble-sep"),
          content_tag(
            :button,
            ICON_IMAGE,
            type: "button",
            title: "Insert image",
            class: "flat-pack-richtext-bubble-btn",
            data: {action: "flat-pack--content-editor#triggerImageUpload"}
          ),
          tag.input(
            type: "file",
            accept: "image/*",
            hidden: true,
            data: {
              flat_pack__content_editor_target: "imageInput",
              action: "change->flat-pack--content-editor#imageInputChanged"
            }
          )
        ]
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
