# frozen_string_literal: true

class CollectionEditorPreview
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :person_id, :integer
  attribute :role, :string

  def persisted?
    id.present?
  end
end
