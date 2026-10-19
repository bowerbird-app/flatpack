# frozen_string_literal: true

class DemoImage < ApplicationRecord
  has_many :project_images, class_name: "DemoProjectImage", inverse_of: :image, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :alt_text, presence: true
  validates :swatch, presence: true
end
