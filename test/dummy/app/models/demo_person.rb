# frozen_string_literal: true

class DemoPerson < ApplicationRecord
  has_many :project_people, class_name: "DemoProjectPerson", foreign_key: :person_id, inverse_of: :person, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}, uniqueness: {case_sensitive: false}
end
