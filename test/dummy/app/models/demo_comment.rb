# frozen_string_literal: true

class DemoComment < ApplicationRecord
  STATES = %w[default system deleted].freeze

  belongs_to :parent_comment, class_name: "DemoComment", optional: true, inverse_of: :replies
  has_many :replies, -> { order(:created_at, :id) }, class_name: "DemoComment", foreign_key: :parent_comment_id, dependent: :destroy, inverse_of: :parent_comment

  scope :root_level, -> { where(parent_comment_id: nil).order(:created_at, :id) }

  validates :author_name, presence: true
  validates :body, presence: true, length: {maximum: 4000}
  validates :state, inclusion: {in: STATES}

  before_validation :normalize_body

  def edited?
    edited_at.present?
  end

  private

  def normalize_body
    self.body = body.to_s.strip
  end
end
