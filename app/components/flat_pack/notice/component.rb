# frozen_string_literal: true

module FlatPack
  module Notice
    # Polite status. Same box as Alert. role is status. Styles are info and success.
    class Component < FlatPack::Shared::StatusMessage
      VARIANTS = FlatPack::Shared::StatusMessage::VARIANTS.slice(:info, :success).freeze
      SIZES = FlatPack::Shared::StatusMessage::SIZES
      ROLE = "status"
    end
  end
end
