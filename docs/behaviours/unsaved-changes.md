# Show unsaved changes on a save button

Attach `flat-pack--unsaved-changes` to a form when the save button should use the default style until someone edits a field.

The form remembers the field values from when the controller connected. That memory is the saved baseline. The form is unsaved only when the current values differ from the baseline. Typing a new title and then typing the original title back marks the form saved again. The first `input` event does not stick.

## Add it to a form

Put the controller on the `<form>`. Mark each save button as a `submit` target. Render the button with `style: :default`.

```erb
<%= form_with model: @profile,
      data: { controller: "flat-pack--unsaved-changes" } do |form| %>

  <%= form.text_field :name %>

  <%= render FlatPack::Button::Component.new(
    text: "Save changes",
    type: "submit",
    style: :default,
    data: {
      "flat-pack--unsaved-changes-target": "submit"
    }
  ) %>
<% end %>
```

A long form can mark a save button at the top and another at the bottom. Both targets follow the same comparison.

Importmap apps load the controller from the existing `controllers/flat_pack` pin. The identifier is `flat-pack--unsaved-changes`.

## What the button does

While the fields match the baseline, each target has `data-fp-style="default"`. When any compared field differs, each target has `data-fp-style="primary"`.

Those are the button component's existing styles. The controller does not copy button classes or set colours. `:default` and `:primary` both use the raised press, so the attribute change is the whole visual change.

The button label stays the same. Colour is extra feedback. It is not the only way to tell that the form has been edited, because the field values themselves have changed.

To use other Flatpack style names, set the values on the form.

```html
data-flat-pack--unsaved-changes-saved-style-value="secondary"
data-flat-pack--unsaved-changes-unsaved-style-value="danger"
```

`:secondary` and `:ghost` use the flat press. Swapping `data-fp-style` updates the colour and leaves the press class that was rendered with the button.

## Which fields count

The comparison reads `input`, `select`, and `textarea` elements in the form. Text fields, textareas, selects, checkboxes, radio buttons, and hidden fields are included. Unchecked checkboxes and unselected radios are omitted, matching what the browser would submit.

Rails fields named `authenticity_token`, `utf8`, and `_method` are ignored. Disabled fields are ignored. Submit buttons are ignored.

The controller listens for `input` and `change` on the form. Flatpack's custom select dispatches `change` from its hidden field. After the rich text editor is ready, later edits dispatch `input` from its hidden field. A combobox choice dispatches `change` from its hidden field.

## Reset and save

Resetting the form restores the original field values, then the controller compares again. When those values match the baseline, the save button returns to the saved style.

A successful Turbo submission that leaves the same form element on the page adopts the current values as the new baseline. `turbo:submit-end` with `detail.success` true does that. A failed submission, including a validation error, leaves the baseline alone, so the button stays in the unsaved style.

When Turbo replaces the form after a save, the new element connects and captures a new baseline. You do not need to reset it yourself.
