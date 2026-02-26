# frozen_string_literal: true

class ChatGroup < ApplicationRecord
  has_many :chat_items, dependent: :destroy

  validates :name, presence: true

  def demo_stream_name
    [self, :chat_demo]
  end
end
