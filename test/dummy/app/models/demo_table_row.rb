# frozen_string_literal: true

class DemoTableRow < ApplicationRecord
  DEFAULT_LIST_KEY = "tables-demo"

  scope :ordered, -> { order(:position, :id) }

  validates :list_key, presence: true
  validates :name, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :position, presence: true
end
