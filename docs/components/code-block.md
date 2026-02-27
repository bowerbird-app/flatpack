# Code Block

## Purpose
Display formatted code snippets with optional multi-tab language switching.

## When to use
Use Code Block in docs, demos, and admin pages where users need copy/readable code examples.

## Class
- Primary: `FlatPack::CodeBlock::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `code` | String | `nil` | conditional | Single snippet content. Required when `snippets` is not provided. |
| `language` | String/Symbol | `nil` | no | Language label/class suffix (adds `language-<lang>` class). |
| `title` | String | derived | no | Header title. Defaults to `Code Example` or `Code Examples`. |
| `snippets` | Array<Hash> | `nil` | conditional | Tabbed snippets. Each hash supports `code`, `label`, `language`. |
| `separated` | Boolean | `true` | no | Adds top margin separation (`mt-4`) when true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for outer wrapper. |

## Slots
None.

## Variants
- Single snippet mode: provide `code`.
- Tabbed mode: provide multiple `snippets` entries.

## Example
```erb
<%= render FlatPack::CodeBlock::Component.new(
  title: "API Requests",
  snippets: [
    {label: "cURL", language: "bash", code: "curl https://api.example.com/items"},
    {label: "Ruby", language: "ruby", code: "Net::HTTP.get(URI(url))"}
  ]
) %>
```

## Accessibility
- Tabbed mode renders `role="tablist"`, `role="tab"`, and `role="tabpanel"` with linked IDs.
- Keyboard support is wired through the tabs Stimulus controller actions.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--code-block-tabs`.
