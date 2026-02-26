# frozen_string_literal: true

class ChatItemAttachment < ApplicationRecord
  KINDS = %w[file image].freeze

  belongs_to :chat_item, inverse_of: :chat_item_attachments

  validates :kind, presence: true, inclusion: {in: KINDS}
  validates :name, presence: true
  validates :content_type, length: {maximum: 255}, allow_blank: true
  validates :byte_size, numericality: {greater_than_or_equal_to: 0, only_integer: true}, allow_nil: true
  validates :position, numericality: {greater_than_or_equal_to: 0, only_integer: true}

  def image?
    kind == "image"
  end

  def file?
    kind == "file"
  end

  def meta_label
    return if byte_size.blank? && content_type.blank?

    [content_type.presence, human_size].compact.join(" • ")
  end

  private

  def human_size
    return if byte_size.blank?

    ActiveSupport::NumberHelper.number_to_human_size(byte_size)
  end
end
