# FlatPack agent notes

FlatPack is a Rails engine. ViewComponents live in `app/components/flat_pack`. Styles live in `app/assets/stylesheets/flat_pack`. JavaScript lives in `app/javascript/flat_pack`. The engine, generators, and version live in `lib/flat_pack`. Translations live in `config/locales`. Component docs live in `docs/components`. Engine tests live in `test/` (`components`, `lib`, `requests`, `system`, `generators`, `integration`). `test/dummy` is the Rails 8 host. `test/dummy-rails-7` is the Rails 7 host. `test/dummy/vendor/flat_pack` is a generated snapshot; change the repo root, not that copy.

## Commands

One engine file:

```bash
bundle exec rails test test/components/flat_pack/button_component_test.rb
```

Engine component and lib suite (`rake test` in the Rakefile):

```bash
bundle exec rake test
```

Full engine suite (CI job `test`):

```bash
bundle exec rails test
```

Rails 8 dummy files the CI job `dummy-app` runs, from `test/dummy`:

```bash
bundle exec rails test test/requests/recording_studio_host_wiring_test.rb test/requests/public_catalog_without_db_test.rb test/requests/locale_switching_test.rb test/controllers/pages_controller_private_test.rb test/requests/pages_gallery_editor_demo_test.rb
```

Rails 7 dummy suite, from `test/dummy-rails-7`:

```bash
bundle exec rails test
```

Lint: `bin/rubocop` (CI runs `bundle exec rubocop`).

Boot the Rails 8 dummy from `test/dummy` with `bin/dev` (Rails, Tailwind watch, Sidekiq, local Redis). Server only: `bin/rails server`.

Version is `FlatPack::VERSION` in `lib/flat_pack/version.rb`.

## Working rules

Read files by line range. Search with a narrow path, `grep -l`, or a result limit. Read only the top CHANGELOG entry, never the whole file. Pipe long command output through `tail`. Run the targeted test file or suite before the full suite. Do not watch CI; GitHub notifies. Open screenshots only for the final check. Do not run multi-model contests unless the user asks.
