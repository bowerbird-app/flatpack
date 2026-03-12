# frozen_string_literal: true

class Article < ApplicationRecord
  BODY_FORMATS = %w[html json].freeze

  validates :title, presence: true, length: {maximum: 255}
  validates :body_format, inclusion: {in: BODY_FORMATS}
end
