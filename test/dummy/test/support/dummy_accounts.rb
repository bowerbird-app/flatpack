# frozen_string_literal: true

module DummyAccounts
  def find_or_create_confirmed_user!(email:, password:)
    user = User.find_or_create_by!(email: email) do |record|
      record.password = password
      record.password_confirmation = password
      record.skip_confirmation! if record.respond_to?(:skip_confirmation!)
    end
    confirm_user!(user)
  end

  def confirm_user!(user)
    return user if user.respond_to?(:confirmed?) && user.confirmed?

    if user.respond_to?(:confirm) && user.confirmation_token.present?
      user.confirm
    end
    return user if user.respond_to?(:confirmed?) && user.confirmed?

    if user.respond_to?(:skip_confirmation!)
      user.skip_confirmation!
    else
      user.confirmed_at = Time.current
    end
    user.save!
    user
  end

  # Recording Studio 7 looks up an existing root. Create it first, then read it back.
  def create_root_recording_then_find!(recordable, actor:)
    RecordingStudio.create_root_recording!(recordable, actor: actor)
    RecordingStudio.root_recording_for(recordable)
  end
end

ActiveSupport::TestCase.include DummyAccounts
