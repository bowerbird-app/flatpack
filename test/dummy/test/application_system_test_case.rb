# frozen_string_literal: true

require "fileutils"
require_relative "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1440, 1440]

  setup do
    self.class.ensure_tailwind_asset!
  end

  def self.ensure_tailwind_asset!
    return if defined?(@tailwind_asset_ready) && @tailwind_asset_ready

    output_path = Rails.root.join("app/assets/builds/tailwind.css")
    return @tailwind_asset_ready = true if output_path.exist?

    FileUtils.mkdir_p(output_path.dirname)

    success = system(
      Gem.bin_path("tailwindcss-rails", "tailwindcss"),
      "-i", Rails.root.join("app/assets/tailwind/application.css").to_s,
      "-o", output_path.to_s
    )

    raise "Tailwind build failed for system tests" unless success

    @tailwind_asset_ready = true
  end
end
