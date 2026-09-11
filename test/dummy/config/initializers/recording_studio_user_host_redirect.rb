# frozen_string_literal: true

# Users auth controllers hardcode after_sign_in_path_for → main_app.root_path.
# On this host the root is the public FlatPack catalog; signed-in people should
# land inside the Recording Studio host home instead.
#
# Do not resume a stored /admin location after password sign-in. Admin returns
# 403 unless the current root is already Admin, so Turbo leaves you on the
# password screen; a second submit then fails CSRF (session was rotated) and
# bounces back to the email step.
Rails.application.config.to_prepare do
  next unless defined?(RecordingStudioUser::Auth::BaseController)

  RecordingStudioUser::Auth::BaseController.class_eval do
    def after_sign_in_path_for(resource)
      location = stored_location_for(resource)
      return main_app.studio_path if location.blank?
      return main_app.studio_path if admin_return_location?(location)

      location
    end

    def after_sign_up_path_for(resource)
      location = stored_location_for(resource)
      return main_app.studio_path if location.blank?
      return main_app.studio_path if admin_return_location?(location)

      location
    end

    private

    def admin_return_location?(location)
      path = location.to_s
      path == "/admin" || path.start_with?("/admin/")
    end
  end

  if defined?(RecordingStudioUser::OmniauthCallbacksController)
    RecordingStudioUser::OmniauthCallbacksController.class_eval do
      def after_sign_in_path_for(_resource)
        main_app.studio_path
      end
    end
  end
end
