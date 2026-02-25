# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  STATES = %w[sent sending failed read].freeze

  belongs_to :chat_group

  scope :chronological, -> { order(:created_at, :id) }

  validates :sender_name, presence: true
  validates :body, presence: true, length: {maximum: 4000}
  validates :state, presence: true, inclusion: {in: STATES}

  before_validation :normalize_body

  def outgoing?
    sender_name == "You"
  end

  private

  def normalize_body
    self.body = body.to_s.strip
  end
end
