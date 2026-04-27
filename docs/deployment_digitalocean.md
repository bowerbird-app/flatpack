# DigitalOcean Deployment for the Dummy App

This guide deploys the Rails demo app in `test/dummy` to DigitalOcean App Platform. It does not turn the FlatPack gem itself into a hosted service.

## What is already wired in this repository

- `test/dummy/config/puma.rb` starts the web process on the port App Platform provides.
- `test/dummy/config/database.yml` keeps production on SQLite, writing to `storage/production.sqlite3` inside the app filesystem.
- `test/dummy/config/environments/production.rb` serves precompiled assets, enables SSL, and uses Sidekiq for Active Job.
- `test/dummy/.do/app.yaml` defines a web service plus a Sidekiq worker for App Platform.
- `test/dummy/Gemfile` and `test/dummy/Gemfile.lock` are deploy-safe and point at `test/dummy/vendor/flat_pack`.
- `test/dummy/Gemfile.app_platform` and `test/dummy/Gemfile.app_platform.lock` mirror the same vendored source for manual deploy-specific Bundler use.
- `test/dummy/bin/refresh_flat_pack_vendor` refreshes that vendored FlatPack snapshot from the repository root.

## Recommended DigitalOcean resources

- One App Platform app
- One managed Redis database
- One custom domain if you want a stable public URL

## Required application secrets

Set these in App Platform before the first successful deploy:

- `SECRET_KEY_BASE`: required
- `REDIS_URL`: required, used by Sidekiq
- `RAILS_SERVE_STATIC_FILES=1`: required so Rails serves Propshaft assets
- `RAILS_FORCE_SSL=true`: recommended
- `ACTIVE_STORAGE_SERVICE=local`: default for the demo app unless you add Spaces-backed storage
- `RAILS_MASTER_KEY`: optional unless you rely on encrypted credentials

## App Platform setup

1. Create a managed Redis cluster.
2. Create an App Platform app from this GitHub repository.
3. Point the app at `test/dummy/.do/app.yaml`, or mirror that file in the App Platform UI.
4. Keep the service source directory set to `test/dummy` so App Platform uses the dummy app's default deploy-safe `Gemfile`.
5. Replace the placeholder secret values from the app spec with your real `SECRET_KEY_BASE` and `REDIS_URL` values.
6. Deploy the web service and worker.
7. After the first deploy, run `bundle exec rails db:prepare` from the App Platform console or a one-off job.
8. Verify `https://your-app.example.com/up` returns healthy before checking demo pages.

## Vendored FlatPack setup

The dummy app's default `test/dummy/Gemfile` points `flat_pack` at the checked-in snapshot under `test/dummy/vendor/flat_pack`.

This avoids both the mutable parent path gem previously used for repo development and the buildpack issues that can occur when App Platform tries to run `bundle exec rake -P` before a git-based dependency is available.

When FlatPack gem code changes in a way that the deployed dummy app should pick up, refresh the vendored snapshot and lockfiles before deploying:

```bash
cd test/dummy
bin/refresh_flat_pack_vendor
bundle lock
BUNDLE_GEMFILE=Gemfile.app_platform bundle lock
```

Commit the updated `vendor/flat_pack` snapshot, `Gemfile.lock`, and `Gemfile.app_platform.lock` along with the app or engine change.

## Commands used by the checked-in app spec

Web build command:

```bash
bundle install && bundle exec rails assets:precompile
```

Web run command:

```bash
bundle exec puma -C config/puma.rb
```

Worker run command:

```bash
bundle exec sidekiq -e production -C config/sidekiq.yml
```

The checked-in app spec also sets:

- `BUNDLE_WITHOUT=development:test`

## Production notes

- The dummy app keeps both SQLite and Active Storage on local disk by default. App Platform filesystems are ephemeral, so the production database and uploads do not persist across rebuilds unless you move them to external services.
- If you want persistent uploads, add a production storage service backed by DigitalOcean Spaces and switch `ACTIVE_STORAGE_SERVICE` to that service name.
- The checked-in app spec disables `deploy_on_push` by default. Enable it if you want every push to `main` to roll out automatically.
- If the deploy starts failing after FlatPack engine changes, refresh `vendor/flat_pack` and regenerate the dummy app lockfiles so the vendored dependency stays aligned with the code you want App Platform to use.