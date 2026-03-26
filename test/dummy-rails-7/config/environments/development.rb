# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.enable_reloading = true

  config.eager_load = false

  config.consider_all_requests_local = true
  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store, {size: 64 * 1024 * 1024}
    config.public_file_server.headers = {"cache-control" => "public, max-age=#{2.days.to_i}"}
  else
    config.action_controller.perform_caching = false
  end

  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
end
