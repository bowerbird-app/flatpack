# frozen_string_literal: true

# The auth shell looks up a site logo. That query used to turn /users/sign_in
# into an empty 500 when Postgres was down or the admin tables were missing.
module DemoAuthSiteLogoGuard
  def auth_site_root_recording
    super
  rescue ActiveRecord::ActiveRecordError => error
    raise unless DemoDatabase.suppress(error)

    nil
  end
end

Rails.application.config.to_prepare do
  next unless defined?(RecordingStudioUser::AuthSiteLogoHelper)

  helper = RecordingStudioUser::AuthSiteLogoHelper
  next if helper.ancestors.include?(DemoAuthSiteLogoGuard)

  helper.prepend(DemoAuthSiteLogoGuard)
end
