# frozen_string_literal: true

# Users auth controllers hardcode after_sign_in_path_for → main_app.root_path.
# On this host the root is the public FlatPack catalog; signed-in people should
# land inside the Recording Studio host home instead.
Rails.application.config.to_prepare do
  next unless defined?(RecordingStudioUser::Auth::BaseController)

  RecordingStudioUser::Auth::BaseController.class_eval do
    def after_sign_in_path_for(resource)
      stored_location_for(resource) || main_app.studio_path
    end

    def after_sign_up_path_for(resource)
      stored_location_for(resource) || main_app.studio_path
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
