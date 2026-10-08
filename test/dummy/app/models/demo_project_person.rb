# frozen_string_literal: true

class DemoProjectPerson < ApplicationRecord
  ROLES = %w[Designer Photographer Producer Editor].freeze

  belongs_to :project, class_name: "DemoProject", inverse_of: :project_people
  belongs_to :person, class_name: "DemoPerson", inverse_of: :project_people

  validates :role, presence: true, inclusion: {in: ROLES}
  validates :position, numericality: {only_integer: true, greater_than: 0}, unless: :marked_for_destruction?
  validate :person_once_per_project, unless: :marked_for_destruction?

  before_validation :ensure_position

  private

  def ensure_position
    return if marked_for_destruction? || position.present?

    taken = project&.project_people&.map(&:position)&.compact
    self.position = (taken&.max || 0) + 1
  end

  def person_once_per_project
    return if person_id.blank? || project.nil?

    taken = project.project_people.any? do |membership|
      next false if membership.equal?(self)
      next false if membership.marked_for_destruction?
      next false if persisted? && membership.persisted? && membership.id == id

      membership.person_id.to_s == person_id.to_s
    end
    return unless taken

    errors.add(:person, "is already a collaborator")
  end
end
