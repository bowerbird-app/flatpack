# DigitalOcean Deployment for the Dummy App

This guide deploys the Rails demo app in `test/dummy` to DigitalOcean App Platform. It does not turn the FlatPack gem itself into a hosted service.

## What is already wired in this repository

- `test/dummy/config/puma.rb` starts the web process on the port App Platform provides.
- `test/dummy/config/database.yml` expects `DATABASE_URL` in production so the dummy app can use managed PostgreSQL.
- `test/dummy/config/environments/production.rb` serves precompiled assets, enables SSL, and uses Sidekiq for Active Job.
- `test/dummy/.do/app.yaml` defines a web service plus a Sidekiq worker for App Platform.
- `test/dummy/Gemfile.app_platform` and `test/dummy/Gemfile.app_platform.lock` give App Platform a deploy-safe Bundler entrypoint that does not depend on the local path gem used for repository development.

## Recommended DigitalOcean resources

- One App Platform app
- One managed PostgreSQL database
- One managed Redis database
- One custom domain if you want a stable public URL

## Required application secrets

Set these in App Platform before the first successful deploy:

- `SECRET_KEY_BASE`: required
- `DATABASE_URL`: required, usually from the managed PostgreSQL cluster
- `REDIS_URL`: required, used by Sidekiq
- `RAILS_SERVE_STATIC_FILES=1`: required so Rails serves Propshaft assets
- `RAILS_FORCE_SSL=true`: recommended
- `ACTIVE_STORAGE_SERVICE=local`: default for the demo app unless you add Spaces-backed storage
- `RAILS_MASTER_KEY`: optional unless you rely on encrypted credentials

## App Platform setup

1. Create a managed PostgreSQL cluster.
2. Create a managed Redis cluster.
3. Create an App Platform app from this GitHub repository.
4. Point the app at `test/dummy/.do/app.yaml`, or mirror that file in the App Platform UI.
5. Keep the service source directory set to `test/dummy` so App Platform uses the dummy app's deploy-specific `Gemfile.app_platform`.
6. Replace the placeholder secret values from the app spec with your real `SECRET_KEY_BASE`, `DATABASE_URL`, and `REDIS_URL` values.
7. Deploy the web service and worker.
8. After the first deploy, run `bundle exec rails db:prepare` from the App Platform console or a one-off job.
9. Verify `https://your-app.example.com/up` returns healthy before checking demo pages.

## Deploy-specific Bundler setup

Local repository development keeps using `test/dummy/Gemfile`, which points `flat_pack` at `../..`.

App Platform uses `test/dummy/Gemfile.app_platform` instead. That file pulls `flat_pack` from the GitHub repository and locks the exact revision in `test/dummy/Gemfile.app_platform.lock`, which avoids Bundler frozen-mode failures caused by mutable path gems.

When FlatPack gem code changes in a way that the deployed dummy app should pick up, refresh the deploy lockfile before deploying:

```bash
cd test/dummy
BUNDLE_GEMFILE=Gemfile.app_platform bundle lock
```

Commit the updated `Gemfile.app_platform.lock` along with the app or engine change.

## Commands used by the checked-in app spec

Web build command:

```bash
export BUNDLE_GEMFILE=Gemfile.app_platform BUNDLE_WITHOUT=development:test && bundle install && bundle exec rails assets:precompile
```

Web run command:

```bash
export BUNDLE_GEMFILE=Gemfile.app_platform BUNDLE_WITHOUT=development:test && bundle exec puma -C config/puma.rb
```

Worker run command:

```bash
export BUNDLE_GEMFILE=Gemfile.app_platform BUNDLE_WITHOUT=development:test && bundle exec sidekiq -e production -C config/sidekiq.yml
```

The checked-in app spec also sets:

- `BUNDLE_GEMFILE=Gemfile.app_platform`
- `BUNDLE_WITHOUT=development:test`

## Production notes

- The dummy app keeps Active Storage on local disk by default. App Platform filesystems are ephemeral, so uploads do not persist across rebuilds unless you add object storage.
- If you want persistent uploads, add a production storage service backed by DigitalOcean Spaces and switch `ACTIVE_STORAGE_SERVICE` to that service name.
- The checked-in app spec disables `deploy_on_push` by default. Enable it if you want every push to `main` to roll out automatically.
- If the deploy starts failing after FlatPack engine changes, regenerate `Gemfile.app_platform.lock` so the deploy-specific git dependency stays aligned with the revision you want App Platform to use.