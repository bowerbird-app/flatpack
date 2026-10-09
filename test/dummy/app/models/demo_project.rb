# frozen_string_literal: true

class DemoProject < ApplicationRecord
  has_many :project_people, -> { order(:position, :id) }, class_name: "DemoProjectPerson", inverse_of: :project, dependent: :destroy
  has_many :people, through: :project_people, source: :person
  has_many :gallery_images, -> { order(:position, :id) }, class_name: "DemoProjectImage", inverse_of: :project, dependent: :destroy

  accepts_nested_attributes_for :project_people, allow_destroy: true, reject_if: :blank_membership?
  accepts_nested_attributes_for :gallery_images, allow_destroy: true, reject_if: :blank_gallery_join?

  validates :name, presence: true

  private

  def blank_membership?(attributes)
    values = attributes.to_h.stringify_keys
    values["id"].blank? && values["person_id"].blank? && values["role"].blank?
  end

  def blank_gallery_join?(attributes)
    values = attributes.to_h.stringify_keys
    values["id"].blank? && values["image_id"].blank? && values["caption"].blank? && values["credit"].blank?
  end
end
