# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout "application"

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
