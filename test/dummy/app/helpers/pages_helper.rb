# frozen_string_literal: true

module PagesHelper
  def demo_button_basic_examples
    [
      {label: "Primary", kwargs: {text: "Primary", style: :primary}},
      {label: "Secondary", kwargs: {text: "Secondary", style: :secondary}},
      {label: "Ghost", kwargs: {text: "Ghost", style: :ghost}},
      {label: "Success", kwargs: {text: "Success", style: :success}},
      {label: "Warning", kwargs: {text: "Warning", style: :warning}}
    ]
  end

  def demo_button_snippets(examples)
    examples.map do |example|
      {
        label: example[:label],
        language: "erb",
        code: demo_component_render_code("FlatPack::Button::Component", example.fetch(:kwargs))
      }
    end
  end

  def picker_demo_full_erb_code(body, items: @picker_demo_items)
    <<~CODE
      #{picker_demo_items_ruby_code(items).strip}

      #{body.strip}
    CODE
  end

  def picker_demo_items_ruby_code(items = @picker_demo_items)
    "@picker_demo_items = #{picker_demo_ruby_value(items, indent: 0)}"
  end

  def picker_demo_items_json_code(items = @picker_demo_items)
    JSON.pretty_generate({items: Array(items).map { |item| picker_demo_json_item(item) }})
  end

  def picker_demo_remote_controller_code(items: @picker_demo_items)
    <<~CODE
      def picker_results
        render json: #{picker_demo_items_json_code(items)}
      end
    CODE
  end

  def picker_demo_local_items_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-local",
        items: @picker_demo_items,
        searchable: true,
        search_mode: :local
      ) %>
    CODE
  end

  def picker_demo_records_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Button::Component.new(
        text: "Open Folder Picker",
        icon: "folder",
        style: :secondary,
        data: {
          action: "click->flat-pack--modal#open",
          "modal-id": "picker-demo-folders"
        }
      ) %>

      <input id="picker-folder-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Folder selection JSON appears here">

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-folders",
        title: "Select Folder",
        subtitle: "Choose one folder record to confirm immediately.",
        items: @picker_demo_items,
        modal: true,
        accepted_kinds: [:record],
        selection_mode: :single,
        auto_confirm: true,
        searchable: true,
        search_mode: :local,
        output_mode: :field,
        output_target: "#picker-folder-field",
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(18rem, 48vh, 24rem)",
        confirm_text: "Use Folder",
        context: { target: "picker-demo-folders" }
      ) %>
    CODE
  end

  def picker_demo_builtin_form_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <% submitted_folder_id = @picker_form_submission.is_a?(Hash) ? @picker_form_submission["folder_record_id"] : nil %>

      <div id="picker-demo-built-in-form-result" class="rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-3">
        <p class="text-xs font-semibold uppercase tracking-wide text-(--surface-muted-content-color)">Last Controller Payload</p>
        <% if submitted_folder_id.present? %>
          <p class="mt-1 text-sm text-(--surface-content-color)"><code>params[:picker_assignment][:folder_record_id]</code></p>
          <p class="mt-1 text-sm font-medium text-(--surface-content-color)"><%= submitted_folder_id %></p>
        <% else %>
          <p class="mt-1 text-sm text-(--surface-muted-content-color)">Submit the picker once to see the controller params reflected here.</p>
        <% end %>
      </div>

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-built-in-form",
        title: "Assign Folder",
        subtitle: "Choose one folder and submit it through a built-in Rails form wrapper.",
        items: @picker_demo_items,
        accepted_kinds: [:record],
        selection_mode: :single,
        searchable: true,
        search_mode: :local,
        confirm_text: "Assign Folder",
        form: {
          url: demo_picker_submissions_path,
          method: :post,
          scope: :picker_assignment,
          field: :folder_record_id,
          value_mode: :id,
          value_path: "payload.record_id",
          turbo: false
        }
      ) %>
    CODE
  end

  def picker_demo_local_search_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Button::Component.new(
        text: "Open Local Picker",
        icon: "image",
        data: {
          action: "click->flat-pack--modal#open",
          "modal-id": "picker-demo-local"
        }
      ) %>

      <div class="rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-3">
        <p class="text-xs font-semibold uppercase tracking-wide text-(--surface-muted-content-color)">Last Confirmed Picker</p>
        <p id="picker-demo-local-last-picker" class="mt-1 text-sm text-(--surface-content-color)" data-picker-demo-output-for="picker-demo-local" data-picker-demo-target="lastPickerId">none</p>
        <p class="text-xs font-semibold uppercase tracking-wide text-(--surface-muted-content-color)">Selection Summary</p>
        <ul id="picker-demo-local-event-output" class="mt-2 space-y-1 text-sm" data-picker-demo-output-for="picker-demo-local" data-picker-demo-target="eventOutput">
          <li class="text-(--surface-muted-content-color)">No items selected yet.</li>
        </ul>
      </div>

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-local",
        title: "Select Assets",
        subtitle: "Local search across image and file assets with a fixed modal body height.",
        items: @picker_demo_items,
        modal: true,
        searchable: true,
        search_mode: :local,
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(20rem, 55vh, 30rem)",
        confirm_text: "Use Selection",
        context: { target: "picker-demo-local" }
      ) %>
    CODE
  end

  def picker_demo_remote_search_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Button::Component.new(
        text: "Open Remote Picker",
        icon: "search",
        style: :secondary,
        data: {
          action: "click->flat-pack--modal#open",
          "modal-id": "picker-demo-remote"
        }
      ) %>

      <div class="rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-3">
        <p class="text-xs font-semibold uppercase tracking-wide text-(--surface-muted-content-color)">Last Confirmed Picker</p>
        <p id="picker-demo-remote-last-picker" class="mt-1 text-sm text-(--surface-content-color)" data-picker-demo-output-for="picker-demo-remote" data-picker-demo-target="lastPickerId">none</p>
        <p class="text-xs font-semibold uppercase tracking-wide text-(--surface-muted-content-color)">Selection Summary</p>
        <ul id="picker-demo-remote-event-output" class="mt-2 space-y-1 text-sm" data-picker-demo-output-for="picker-demo-remote" data-picker-demo-target="eventOutput">
          <li class="text-(--surface-muted-content-color)">No items selected yet.</li>
        </ul>
      </div>

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-remote",
        title: "Search Remote Assets",
        subtitle: "Remote search keeps a fixed modal body height for stable layout while result counts change.",
        items: @picker_demo_items.first(2),
        modal: true,
        searchable: true,
        search_mode: :remote,
        search_endpoint: demo_picker_results_path,
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(20rem, 55vh, 30rem)",
        confirm_text: "Use Remote Selection",
        context: { target: "picker-demo-remote" }
      ) %>
    CODE
  end

  def picker_demo_inline_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <input id="picker-inline-selected-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Inline selection JSON appears here">

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-inline",
        title: "Inline Asset Picker",
        subtitle: "Choose one item to confirm immediately.",
        items: @picker_demo_items,
        searchable: true,
        search_mode: :local,
        selection_mode: :single,
        auto_confirm: true,
        modal: false,
        output_mode: :field,
        output_target: "#picker-inline-selected-field",
        confirm_text: "Use Inline Selection",
        context: { target: "picker-demo-inline" }
      ) %>
    CODE
  end

  def picker_demo_items_height_min_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-items-height-min",
        title: "Min Content",
        subtitle: "One result keeps the list region compact.",
        items: @picker_demo_items.first(1),
        searchable: true,
        search_mode: :local,
        items_height: "min-content",
        modal: false,
        selection_mode: :single,
        confirm_text: "Use Asset"
      ) %>
    CODE
  end

  def picker_demo_items_height_max_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-items-height-max",
        title: "Max Content",
        subtitle: "The results region expands to fill the wrapper.",
        items: @picker_demo_items,
        searchable: true,
        search_mode: :local,
        items_height: "max-content",
        modal: false,
        confirm_text: "Use Assets"
      ) %>
    CODE
  end

  def picker_demo_items_height_fixed_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-items-height-fixed",
        title: "Fixed Height",
        subtitle: "A 240px results region scrolls once content exceeds the cap.",
        items: @picker_demo_items,
        searchable: true,
        search_mode: :local,
        items_height: "240px",
        modal: false,
        confirm_text: "Use Assets"
      ) %>
    CODE
  end

  def picker_demo_images_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Button::Component.new(
        text: "Open Image Picker",
        icon: "image",
        data: {
          action: "click->flat-pack--modal#open",
          "modal-id": "picker-demo-images"
        }
      ) %>

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-images",
        title: "Select Image",
        subtitle: "Choose one or more image assets.",
        items: @picker_demo_items,
        modal: true,
        accepted_kinds: [:image],
        selection_mode: :multiple,
        searchable: true,
        search_mode: :local,
        results_layout: :grid,
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(18rem, 50vh, 26rem)",
        confirm_text: "Use Image",
        context: { target: "picker-demo-images" }
      ) %>
    CODE
  end

  def picker_demo_single_select_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Button::Component.new(
        text: "Open Auto-Confirm Picker",
        icon: "image",
        style: :secondary,
        data: {
          action: "click->flat-pack--modal#open",
          "modal-id": "picker-demo-auto-confirm"
        }
      ) %>

      <input id="picker-auto-confirm-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Auto-confirm selection JSON appears here">

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-auto-confirm",
        title: "Choose One Asset",
        subtitle: "Selecting an item confirms immediately and closes the modal.",
        items: @picker_demo_items,
        modal: true,
        searchable: true,
        search_mode: :local,
        selection_mode: :single,
        auto_confirm: true,
        output_mode: :field,
        output_target: "#picker-auto-confirm-field",
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(18rem, 50vh, 24rem)",
        confirm_text: "Use Asset",
        context: { target: "picker-demo-auto-confirm" }
      ) %>
    CODE
  end

  def picker_demo_field_output_erb_code
    picker_demo_full_erb_code(<<~CODE)
      <%= render FlatPack::Button::Component.new(
        text: "Open Field Picker",
        icon: "file",
        data: {
          action: "click->flat-pack--modal#open",
          "modal-id": "picker-demo-field"
        }
      ) %>

      <input id="picker-selected-assets-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Selected JSON appears here">

      <%= render FlatPack::Picker::Component.new(
        id: "picker-demo-field",
        title: "Select Files",
        subtitle: "Writes selected items to a consumer-provided field selector.",
        items: @picker_demo_items,
        modal: true,
        accepted_kinds: [:file],
        searchable: true,
        search_mode: :local,
        modal_body_height_mode: :fixed,
        modal_body_height: "24rem",
        output_mode: :field,
        output_target: "#picker-selected-assets-field",
        confirm_text: "Store Selection",
        context: { target: "picker-demo-field" }
      ) %>
    CODE
  end

  private

  def picker_demo_json_item(item)
    source = (item || {}).deep_stringify_keys

    {
      id: source["id"],
      kind: source["kind"],
      title: source["title"] || source["label"],
      name: source["name"],
      icon: source["icon"],
      contentType: source["content_type"],
      byteSize: source["byte_size"],
      thumbnail_url: source["thumbnail_url"],
      description: source["description"],
      right_text: source["right_text"],
      path: source["path"],
      badge: source["badge"],
      meta: source["meta"],
      payload: source["payload"] || {}
    }.compact
  end

  def picker_demo_ruby_value(value, indent:)
    case value
    when Array
      return "[]" if value.empty?

      inner_indent = " " * (indent + 2)
      closing_indent = " " * indent

      "[\n#{value.map { |item| "#{inner_indent}#{picker_demo_ruby_value(item, indent: indent + 2)}" }.join(",\n")}\n#{closing_indent}]"
    when Hash
      return "{}" if value.empty?

      inner_indent = " " * (indent + 2)
      closing_indent = " " * indent

      "{\n#{value.map { |key, item| "#{inner_indent}#{key}: #{picker_demo_ruby_value(item, indent: indent + 2)}" }.join(",\n")}\n#{closing_indent}}"
    when Symbol
      ":#{value}"
    when String
      value.inspect
    else
      value.inspect
    end
  end

  def demo_component_render_code(component_name, kwargs)
    rendered_kwargs = kwargs.map { |key, value| "#{key}: #{demo_code_value(value)}" }.join(", ")
    "<%= render #{component_name}.new(#{rendered_kwargs}) %>"
  end

  def demo_code_value(value)
    case value
    when Symbol
      ":#{value}"
    when String
      value.inspect
    else
      value.inspect
    end
  end
end
