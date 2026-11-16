# frozen_string_literal: true

Rails.application.config.to_prepare do
  ActionController::Base.helper DummyRecordingStudioPageNavHelper
end
