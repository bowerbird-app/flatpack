# FlatPack Dummy Application

This is a Rails 8 application that demonstrates the FlatPack component library.

## Purpose

This dummy app serves as:
- A testing environment for the FlatPack gem during development
- A demo/showcase of FlatPack components
- Reference implementation showing how to integrate FlatPack into a Rails app

## Setup

The dummy app is configured to use the checked-in FlatPack snapshot at `vendor/flat_pack`.

### Quick Setup

Run the setup script to automatically install all dependencies and prepare the app:

```bash
bin/setup --skip-server
```

This will:
- Install all Ruby gem dependencies (including the vendored FlatPack snapshot)
- Prepare the database
- Build Tailwind CSS assets
- Clear logs and temporary files

### Manual Installation Steps

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Setup the database:**
   ```bash
   bin/rails db:create db:migrate
   ```

3. **Build Tailwind CSS:**
  ```bash
  bundle exec tailwindcss -i app/assets/stylesheets/application.css -o app/assets/builds/application.css
  ```

  `application.css` re-exports `application.tailwind.css` (tokens stay in `flat_pack/variables`; no `--color-fp-*` fork).

4. **Start the server:**
   ```bash
   bin/rails server
   ```

5. **Visit the app:**
   Open http://localhost:3000 in your browser

## FlatPack Integration

The dummy app demonstrates proper FlatPack installation:

### 1. Gemfile Configuration

The FlatPack gem is loaded from the checked-in vendor directory:

```ruby
gem "flat_pack", path: "vendor/flat_pack"
```

### 2. Stylesheet load order

The dummy app loads gem CSS first, then the compiled host Tailwind bundle last (`layouts/_flat_pack_stylesheets.html.erb`):

```erb
<%= stylesheet_link_tag "flat_pack/variables", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "flat_pack/application", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "flat_pack/rich_text", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "flat_pack/content_editor", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

Tokens come from `flat_pack/variables`. Do not `@import "flat_pack/variables.css"` in a Propshaft-served stylesheet (fingerprinted filenames 404). Do not fork tokens as `--color-fp-*` in the Tailwind entry.

Host overrides (for example `[data-theme="sunrise"] { --brand-hue: 35; --brand-chroma: 0.19; --brand-lightness: 0.52; }`) live in `app/assets/stylesheets/application.tailwind.css` and win because `application` loads last.

### 3. Tailwind Configuration

The Tailwind CSS 4 entrypoint includes both the dummy app and FlatPack component sources:

```css
@import "tailwindcss" source(none);
@source "../..";
@source "../../../../../app";
```

### 4. Importmap Configuration

FlatPack contributes its importmap pins through the engine's `config/importmap.rb`. The dummy app adds only app-specific pins in `test/dummy/config/importmap.rb`.

Stimulus loads the engine controllers under the `flat-pack--*` identifiers used by component markup.

### 5. Engine Mount

The FlatPack engine is mounted in `config/routes.rb`:

```ruby
mount FlatPack::Engine => "/flat_pack"
```

## Demo Pages

The dummy app includes several demo pages:

- **Home/Demo** (`/`): Overview of available components
- **Buttons** (`/demo/buttons`): Button component examples
- **Tables** (`/demo/tables`): Table component examples
- **Themes** (`/themes`): Live `@theme` token catalog (brand → semantic → component aliases)
- **Theme demos** (`/themes/demos/:theme`): Light (`:root` dump) plus override-only named themes

## Development

When developing FlatPack components, update the dummy app snapshot before testing:

1. Making changes to components in the parent `app/components` directory
2. Running `ruby test/dummy/bin/refresh_flat_pack_vendor` from the repository root
3. Rebuilding CSS or restarting the app when the changed assets require it

## Using Components

Example usage in views:

```erb
<%# Button Component %>
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  style: :primary
) %>

<%# Table Component %>
<%= render FlatPack::Table::Component.new do |table| %>
  <% table.column(title: "Name") { |row| row.name } %>
  <% table.column(title: "Email") { |row| row.email } %>
<% end %>
```

## Testing

Run tests from the parent directory:

```bash
cd ../..
bundle exec rake test
```

## Deployment

The dummy app can be deployed to DigitalOcean App Platform with the checked-in example spec at `test/dummy/.do/app.yaml`.

- The default dummy `Gemfile` and `Gemfile.lock` point at the checked-in `vendor/flat_pack` snapshot, so App Platform can use the standard Bundler flow.
- `Gemfile.app_platform` mirrors the same vendored source for manual deploy-specific Bundler use.
- Production stays on SQLite via `storage/production.sqlite3`
- The checked-in App Platform spec runs `rails db:prepare` in the web command so the web instance initializes its own local SQLite database
- Active Job defaults to `async` for the SQLite App Platform path, so the demo runs on a single web service by default
- Set `SECRET_KEY_BASE` in App Platform secrets

When FlatPack engine changes should be reflected in App Platform, refresh the vendored engine snapshot and lockfiles:

```bash
cd test/dummy
bin/refresh_flat_pack_vendor
bundle lock
BUNDLE_GEMFILE=Gemfile.app_platform bundle lock
```

See [../../docs/deployment_digitalocean.md](../../docs/deployment_digitalocean.md) for the full setup flow.

## Directory Structure

```text
test/dummy/
├── app/
│   ├── assets/
│   │   ├── stylesheets/application.css            # CI/build entry (imports application.tailwind.css)
│   │   ├── stylesheets/application.tailwind.css
│   │   └── tailwind/application.css
│   ├── controllers/pages_controller.rb
│   ├── javascript/controllers/
│   └── views/pages/
├── config/
│   ├── importmap.rb
│   └── routes.rb
├── vendor/flat_pack/                # Checked-in engine snapshot
└── Gemfile                          # References vendor/flat_pack
```
