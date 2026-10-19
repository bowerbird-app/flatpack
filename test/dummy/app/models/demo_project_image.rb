# frozen_string_literal: true

class DemoProjectImage < ApplicationRecord
  belongs_to :project, class_name: "DemoProject", inverse_of: :gallery_images
  belongs_to :image, class_name: "DemoImage", inverse_of: :project_images

  validates :position, numericality: {only_integer: true, greater_than: 0}, unless: :marked_for_destruction?
  validate :image_present, unless: :marked_for_destruction?
  validate :image_once_per_project, unless: :marked_for_destruction?

  before_validation :ensure_position

  private

  def ensure_position
    return if marked_for_destruction? || position.present?

    taken = project&.gallery_images&.map(&:position)&.compact
    self.position = (taken&.max || 0) + 1
  end

  def image_present
    return if image_id.present?

    errors.add(:image, "must be chosen")
  end

  def image_once_per_project
    return if image_id.blank? || project.nil?
    return if persisted? && !image_id_changed?

    taken = project.gallery_images.any? do |join|
      next false if join.equal?(self)
      next false if join.marked_for_destruction?
      next false if persisted? && join.persisted? && join.id == id

      join.image_id.to_s == image_id.to_s
    end
    return unless taken

    errors.add(:image, "is already on this page")
  end
end
