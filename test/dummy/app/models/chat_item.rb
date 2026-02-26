# frozen_string_literal: true

class ChatItem < ApplicationRecord
  STATES = %w[sent sending failed read].freeze
  ITEM_TYPES = %w[text attachment mixed].freeze

  belongs_to :chat_group
  has_many :chat_item_attachments, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :chat_item

  accepts_nested_attributes_for :chat_item_attachments, allow_destroy: true

  scope :chronological, -> { order(:created_at, :id) }

  validates :sender_name, presence: true
  validates :body, length: {maximum: 4000}, allow_blank: true
  validates :state, presence: true, inclusion: {in: STATES}
  validates :item_type, presence: true, inclusion: {in: ITEM_TYPES}
  validate :must_have_body_or_attachments

  before_validation :normalize_body
  before_validation :set_item_type

  def outgoing?
    sender_name == "You"
  end

  def attachments?
    chat_item_attachments.any?
  end

  private

  def normalize_body
    self.body = body.to_s.strip
    self.body = nil if body.blank?
  end

  def set_item_type
    has_body = body.present?
    has_attachments = chat_item_attachments.reject(&:marked_for_destruction?).any?

    self.item_type = if has_body && has_attachments
      "mixed"
    elsif has_attachments
      "attachment"
    else
      "text"
    end
  end

  def must_have_body_or_attachments
    return if body.present?
    return if chat_item_attachments.reject(&:marked_for_destruction?).any?

    errors.add(:base, "Message or attachments can't be blank")
  end
end
