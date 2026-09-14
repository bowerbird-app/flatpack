# frozen_string_literal: true

return unless defined?(RecordingStudioUser)

RecordingStudioUser.configure do |config|
  config.user_class_name = "User"
  config.layout = "recording_studio/default_layout"
  # Password-only demo: set methods before flipping OTP flags.
  config.registration_authentication_methods = %i[password]
  config.otp_enabled = false
  config.otp_login_enabled = false
  config.otp_registration_enabled = false
  config.password_registration_confirmation = :existing_policy
  config.omniauth_create_account = true
end
