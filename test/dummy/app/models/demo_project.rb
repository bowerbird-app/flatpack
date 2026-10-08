# frozen_string_literal: true

class DemoProject < ApplicationRecord
  has_many :project_people, -> { order(:position, :id) }, class_name: "DemoProjectPerson", inverse_of: :project, dependent: :destroy
  has_many :people, through: :project_people, source: :person

  accepts_nested_attributes_for :project_people, allow_destroy: true, reject_if: :blank_membership?

  validates :name, presence: true

  private

  def blank_membership?(attributes)
    values = attributes.to_h.stringify_keys
    values["id"].blank? && values["person_id"].blank? && values["role"].blank?
  end
end
