# Engine Architecture

FlatPack is built as a Rails Engine using the `isolate_namespace` pattern for maximum compatibility with host applications.

## Overview

```
flat_pack/
├── lib/flat_pack/engine.rb    # Engine configuration
├── app/components/             # ViewComponents
├── app/assets/                 # Stylesheets
├── app/javascript/             # Stimulus controllers
└── config/                     # Routes and importmap
```

## Engine Configuration

### Namespace Isolation

```ruby
module FlatPack
  class Engine < ::Rails::Engine
    isolate_namespace FlatPack
  end
end
```

Benefits:
- No naming conflicts with host app
- Clean module structure
- Easy to reason about dependencies

### Autoload Paths

```ruby
config.autoload_paths << root.join("app/components")
```

Ensures Zeitwerk can load `FlatPack::Button::Component`.

### ViewComponent Configuration

```ruby
config.view_component.view_component_path = root.join("app/components")
```

Tells ViewComponent where to find component classes and templates.

## Component Architecture

### Base Component

All components inherit from `FlatPack::BaseComponent`:

```ruby
module FlatPack
  class BaseComponent < ViewComponent::Base
    include TailwindMerge::Rails::ViewHelper
    
    def initialize(**system_arguments)
      @system_arguments = system_arguments
    end
  end
end
```

Provides:
- System arguments pattern
- TailwindMerge integration
- Consistent API across components

### Component Structure

```
app/components/flat_pack/button/
├── component.rb          # Component logic
└── component.html.erb    # Component template
```

Or for simple components, template can be omitted and `#call` method used.

## Integration Points

### With Host Application

The engine integrates via:

1. **Stylesheet Import**
   ```css
   @import "flat_pack/variables.css";
   ```

2. **Component Rendering**
   ```erb
   <%= render FlatPack::Button::Component.new(...) %>
   ```

3. **Stimulus Controllers**
   ```js
   // Auto-registered via importmap
   import { Controller } from "@hotwired/stimulus"
   ```

### Asset Pipeline (Propshaft)

```ruby
initializer "flat_pack.assets" do |app|
  app.config.assets.paths << root.join("app/assets/stylesheets")
  app.config.assets.paths << root.join("app/javascript")
end
```

Propshaft automatically serves assets from these paths.

### Importmap

```ruby
initializer "flat_pack.importmap", before: "importmap" do |app|
  app.config.importmap.paths << root.join("config/importmap.rb")
end
```

Registers FlatPack's JavaScript modules.

## Design Patterns

### System Arguments

Consistent interface for HTML attributes:

```ruby
FlatPack::Button::Component.new(
  text: "Click me",
  class: "mt-4",
  data: { action: "click" },
  aria: { label: "Custom" }
)
```

### TailwindMerge Integration

Intelligently merges Tailwind classes:

```ruby
def classes(*additional_classes)
  base_classes = @system_arguments.delete(:class) || ""
  tailwind_merge(base_classes, *additional_classes.compact)
end
```

Allows overriding without `!important`.

### Composition with Slots

```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.with_column(title: "Name", attribute: :name) %>
  <% table.with_action(text: "Edit", url: ...) %>
<% end %>
```

Uses ViewComponent's `renders_many` for flexible composition.

## Testing Strategy

### Component Tests

```ruby
class ComponentTest < ViewComponent::TestCase
  def test_renders_button
    render_inline FlatPack::Button::Component.new(text: "Test")
    assert_selector "button", text: "Test"
  end
end
```

### Dummy Application

Located in `test/dummy`, provides:
- Integration testing environment
- Component previews
- Development server

## Configuration Options

### Engine-level Configuration

```ruby
FlatPack.configure do |config|
  config.default_theme = :light
end
```

### Component-level Configuration

Via CSS variables in host application:

```css
@theme {
  --color-primary: oklch(0.62 0.22 250);
}
```

## Loading Order

1. Rails loads engine gem
2. Engine initializers run
3. Asset paths registered with Propshaft
4. Importmap paths registered
5. ViewComponent discovers components
6. Host application can render components

## Namespace Conventions

All code is namespaced under `FlatPack`:

```ruby
FlatPack::Button::Component
FlatPack::Table::Component
FlatPack::Table::ColumnComponent
FlatPack::Shared::IconComponent
```

Database tables would be prefixed (if any):
```ruby
flat_pack_error_logs
flat_pack_audit_trails
```

## Upgrade Strategy

### Backward Compatibility

- Semantic versioning (MAJOR.MINOR.PATCH)
- Deprecation warnings before removal
- Migration guides in CHANGELOG.md

### Breaking Changes

Documented clearly:

```markdown
## [2.0.0] - Breaking Changes

### Button Component
- Removed `size` prop (use `class` instead)
- Renamed `variant` to `scheme`
```

## Performance Considerations

### ViewComponent Benefits

- Server-side rendering (no hydration cost)
- Caching support
- Ruby performance

### CSS Variables

- No runtime recalculation
- Browser-optimized
- Cascade properly

### Minimal JavaScript

- Only where needed (table interactions)
- Progressive enhancement
- Degrades gracefully

## Security

### No Business Logic

Components are presentation-only:
- No database queries
- No authorization checks
- No data mutations

### Safe Defaults

- Attributes are escaped by Rails
- No unsafe HTML rendering
- CSRF protection via Rails

## Next Steps

- [Asset Pipeline](assets.md)
- [Tailwind CSS 4 Integration](tailwind_4.md)
- [Contributing Guide](../../README.md#contributing)
