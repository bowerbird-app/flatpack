# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = {"cache-control" => "public, max-age=#{2.days.to_i}"}
  else
    config.action_controller.perform_caching = false
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true
  # Use async by default so demo background interactions (chat typing/replies)
  # work even when Sidekiq is not running. Opt into Sidekiq explicitly.
  config.active_job.queue_adapter = if ENV["DUMMY_USE_SIDEKIQ"] == "1" &&
      Gem::Specification.find_all_by_name("sidekiq").any?
    :sidekiq
  else
    :async
  end

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Allow GitHub Codespaces hosts
  config.hosts << /.*\.app\.github\.dev/

  # Allow local forwarded origins (e.g. http://localhost:3000) when developing
  # through Codespaces/browser tunnels so CSRF origin checks don't block demo
  # XHR PATCH requests like /demo/tables/reorder.
  config.action_controller.forgery_protection_origin_check = false

  # Ensure importmap fingerprints are refreshed when FlatPack engine controllers
  # change during development, preventing stale digested module URLs.
  config.importmap.cache_sweepers << FlatPack::Engine.root.join("app/javascript/flat_pack/controllers")
end
