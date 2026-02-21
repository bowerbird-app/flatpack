# frozen_string_literal: true

class DummyDatum < ApplicationRecord
  STATUSES = %w[active inactive pending archived].freeze
  CATEGORIES = %w[engineering marketing sales product support].freeze

  scope :ordered, -> { order(:position, :id) }
  scope :recent, -> { order(published_at: :desc, id: :desc) }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :category, presence: true, inclusion: {in: CATEGORIES}
  validates :views_count, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :position, presence: true, uniqueness: true, numericality: {greater_than: 0}
  validates :published_at, presence: true
end
