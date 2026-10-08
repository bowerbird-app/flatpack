# frozen_string_literal: true

module FlatPack
  # Interface copy for kit chrome. Keys live under `flatpack.*`.
  # Hosts override any key in their own locale files. Explicit component
  # props still win over these defaults.
  module Copy
    NAMESPACE = "flatpack"
    OMITTED = Object.new.freeze

    JS_KEYS = %w[
      password.show
      password.hide
      chip.remove
      select.remove
      search.result_fallback
      picker.untitled
      pagination.error_loading
      pagination.loading
      file_input.size_exceeded
      file_input.size_bytes
      file_input.size_kilobytes
      file_input.size_megabytes
      form.please_select
      form.invalid_selection
      form.invalid_value
      text.characters
      text.characters_with_limit
      rich_text.placeholder
      rich_text.anonymous
      rich_text.insert_content
      rich_text.bold
      rich_text.italic
      rich_text.underline
      rich_text.strikethrough
      rich_text.inline_code
      rich_text.highlight
      rich_text.heading_1
      rich_text.heading_2
      rich_text.heading_3
      rich_text.bullet_list
      rich_text.numbered_list
      rich_text.task_list
      rich_text.blockquote
      rich_text.align_left
      rich_text.align_center
      rich_text.align_right
      rich_text.insert_link
      rich_text.link
      rich_text.insert_image
      rich_text.insert_table
      rich_text.undo
      rich_text.redo
      rich_text.link_placeholder
      rich_text.apply
      rich_text.remove
      rich_text.image_placeholder
      rich_text.insert
      rich_text.upload_from_computer
      rich_text.uploading
      rich_text.upload_failed
      rich_text.upload_failed_connection
      rich_text.enter_link_url
      rich_text.text_formatting
      rich_text.or_upload
      rich_text.upload_image_file
      timestamp.just_now
      timestamp.a_min_ago
      timestamp.minutes_ago
      timestamp.hours_ago
      timestamp.yesterday
      timestamp.days_ago
      timestamp.weeks_ago
      timestamp.months_ago
      timestamp.short_a_min_ago
      timestamp.short_min_ago
      timestamp.short_hr_ago
      timestamp.short_yesterday
      timestamp.short_d_ago
      timestamp.short_wk_ago
      timestamp.short_mo_ago
      content_editor.image_upload_failed
      content_editor.edit_url
      content_editor.enter_url
      content_editor.save_failed
      date_picker.summary
      chat.you
      chat.attachment
      chat.sending
      chat.failed
      clipboard.nothing
      clipboard.copied
      clipboard.unable
    ].freeze

    module_function

    def t(key, **options)
      I18n.t("#{NAMESPACE}.#{key}", **options)
    end

    # Omitted keywords use the locale default. `nil` and other values, including
    # a blank string, are explicit overrides.
    def text(given, key, **options)
      given.equal?(OMITTED) ? t(key, **options) : given
    end

    def interpolate(template, **variables)
      template.to_s.gsub(/%\{(\w+)\}/) { |_| variables[Regexp.last_match(1).to_sym].to_s }
    end

    def js_payload
      JS_KEYS.each_with_object({}) do |key, payload|
        payload[key] = t(key)
      end
    end
  end
end
