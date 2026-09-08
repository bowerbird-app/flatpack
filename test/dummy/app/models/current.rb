# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :actor, :impersonator
end
