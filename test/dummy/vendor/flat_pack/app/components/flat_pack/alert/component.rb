# frozen_string_literal: true

module FlatPack
  module Alert
    # Urgent status. The box is FlatPack::Shared::StatusMessage. role is alert.
    class Component < FlatPack::Shared::StatusMessage
      VARIANTS = FlatPack::Shared::StatusMessage::VARIANTS
      SIZES = FlatPack::Shared::StatusMessage::SIZES
      ROLE = "alert"
    end
  end
end
