# frozen_string_literal: true

class CollectionEditorTextLine
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :item, :string
  attribute :detail, :string
  attribute :note, :string

  def persisted?
    false
  end
end
