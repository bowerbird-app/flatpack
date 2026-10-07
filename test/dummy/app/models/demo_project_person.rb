# frozen_string_literal: true

class DemoProjectPerson < ApplicationRecord
  ROLES = %w[Designer Photographer Producer Editor].freeze

  belongs_to :project, class_name: "DemoProject", inverse_of: :project_people
  belongs_to :person, class_name: "DemoPerson", inverse_of: :project_people

  validates :role, presence: true, inclusion: {in: ROLES}
  validates :position, numericality: {only_integer: true, greater_than: 0}, unless: :marked_for_destruction?

  before_validation :ensure_position

  private

  def ensure_position
    return if marked_for_destruction? || position.present?

    taken = project&.project_people&.map(&:position)&.compact
    self.position = (taken&.max || 0) + 1
  end
end
