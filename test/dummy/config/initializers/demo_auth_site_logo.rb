# frozen_string_literal: true

# The auth shell looks up a site logo. That query used to turn /users/sign_in
# into an empty 500 when Postgres was down or the admin tables were missing.
Rails.application.config.to_prepare do
  next unless defined?(RecordingStudioUser::AuthSiteLogoHelper)

  helper = RecordingStudioUser::AuthSiteLogoHelper
  next if helper.method_defined?(:auth_site_root_recording_without_demo_database)

  helper.module_eval do
    def auth_site_root_recording_with_demo_database
      auth_site_root_recording_without_demo_database
    rescue *DemoDatabase::ERRORS
      nil
    end

    alias_method :auth_site_root_recording_without_demo_database, :auth_site_root_recording
    alias_method :auth_site_root_recording, :auth_site_root_recording_with_demo_database
  end
end
