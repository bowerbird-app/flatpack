# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.enable_reloading = false

  config.eager_load = ENV["CI"].present?

  config.public_file_server.headers = {"cache-control" => "public, max-age=#{1.hour.to_i}"}

  config.consider_all_requests_local = true
  config.server_timing = true

  config.action_dispatch.show_exceptions = :rescuable

  config.action_controller.allow_forgery_protection = false

  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
end
