const ENGLISH = {
  "password.show": "Show password",
  "password.hide": "Hide password",
  "chip.remove": "Remove",
  "select.remove": "Remove %{label}",
  "search.result_fallback": "Result",
  "picker.untitled": "Untitled",
  "pagination.error_loading": "Error loading. Try again.",
  "pagination.loading": "Loading…",
  "file_input.size_exceeded": "File \"%{name}\" exceeds maximum size of %{size}",
  "file_input.size_bytes": "%{count}B",
  "file_input.size_kilobytes": "%{count}KB",
  "file_input.size_megabytes": "%{count}MB",
  "form.please_select": "Please select an option.",
  "form.invalid_selection": "Invalid selection.",
  "form.invalid_value": "Invalid value.",
  "text.characters": "%{count} characters",
  "text.characters_with_limit": "%{count}/%{limit} characters",
  "rich_text.placeholder": "Start writing…",
  "rich_text.anonymous": "Anonymous",
  "rich_text.insert_content": "Insert content",
  "rich_text.bold": "Bold",
  "rich_text.italic": "Italic",
  "rich_text.underline": "Underline",
  "rich_text.strikethrough": "Strikethrough",
  "rich_text.inline_code": "Inline code",
  "rich_text.highlight": "Highlight",
  "rich_text.heading_1": "Heading 1",
  "rich_text.heading_2": "Heading 2",
  "rich_text.heading_3": "Heading 3",
  "rich_text.bullet_list": "Bullet list",
  "rich_text.numbered_list": "Numbered list",
  "rich_text.task_list": "Task list",
  "rich_text.blockquote": "Blockquote",
  "rich_text.align_left": "Align left",
  "rich_text.align_center": "Align center",
  "rich_text.align_right": "Align right",
  "rich_text.insert_link": "Insert/edit link",
  "rich_text.link": "Link",
  "rich_text.insert_image": "Insert image",
  "rich_text.insert_table": "Insert table",
  "rich_text.undo": "Undo",
  "rich_text.redo": "Redo",
  "rich_text.link_placeholder": "https://",
  "rich_text.apply": "Apply",
  "rich_text.remove": "Remove",
  "rich_text.image_placeholder": "Image URL (https://...)",
  "rich_text.insert": "Insert",
  "rich_text.upload_from_computer": "Upload from computer",
  "rich_text.uploading": "Uploading…",
  "rich_text.upload_failed": "Upload failed",
  "rich_text.upload_failed_connection": "Upload failed — check your connection",
  "rich_text.enter_link_url": "Enter link URL:",
  "rich_text.text_formatting": "Text formatting",
  "rich_text.or_upload": "— or upload a file —",
  "rich_text.upload_image_file": "Upload image file",
  "timestamp.just_now": "Just now",
  "timestamp.a_min_ago": "a min ago",
  "timestamp.minutes_ago": "%{count} minutes ago",
  "timestamp.hours_ago": "%{count} hours ago",
  "timestamp.yesterday": "Yesterday",
  "timestamp.days_ago": "%{count} days ago",
  "timestamp.weeks_ago": "%{count} weeks ago",
  "timestamp.months_ago": "%{count} months ago",
  "timestamp.short_a_min_ago": "a min ago",
  "timestamp.short_min_ago": "%{count} min ago",
  "timestamp.short_hr_ago": "%{count}hr ago",
  "timestamp.short_yesterday": "1d ago",
  "timestamp.short_d_ago": "%{count}d ago",
  "timestamp.short_wk_ago": "%{count}wk ago",
  "timestamp.short_mo_ago": "%{count}mo ago",
  "content_editor.image_upload_failed": "Image upload failed.",
  "content_editor.edit_url": "Edit URL (leave blank to remove):",
  "content_editor.enter_url": "Enter URL:",
  "content_editor.save_failed": "Save failed. Please try again.",
  "date_picker.summary": "Select a date from calendar or use a quick range preset.",
  "chat.you": "You",
  "chat.attachment": "Attachment",
  "chat.sending": "Sending...",
  "chat.failed": "Failed",
  "clipboard.nothing": "Nothing to copy",
  "clipboard.copied": "Copied to clipboard",
  "clipboard.unable": "Unable to copy"
}

function payload() {
  const raw = document.documentElement?.dataset?.fpCopy
  if (!raw) return {}

  try {
    return JSON.parse(raw)
  } catch {
    return {}
  }
}

export function interpolateCopy(template, vars = {}) {
  return String(template ?? "").replace(/%\{(\w+)\}/g, (_, name) => {
    const value = vars[name]
    return value == null ? "" : String(value)
  })
}

export function flatPackCopy(key, vars = {}) {
  const template = payload()[key] ?? ENGLISH[key] ?? key
  return interpolateCopy(template, vars)
}
