# frozen_string_literal: true

class CollectionEditorDemo
  LAUNCH = "Launch film"
  EMPTY = "Empty collection"
  LOCK_KEY = 914_200

  PEOPLE = [
    ["Alice Chen", "alice@example.com"],
    ["Daniel Lee", "daniel@example.com"],
    ["Priya Shah", "priya@example.com"],
    ["Alice Chen-Smith", "alice@studio.example"]
  ].freeze

  MEMBERSHIPS = [
    ["alice@example.com", "Designer"],
    ["daniel@example.com", "Photographer"],
    ["priya@example.com", "Producer"]
  ].freeze

  def self.ensure!
    DemoProject.transaction do
      DemoProject.connection.execute("SELECT pg_advisory_xact_lock(#{LOCK_KEY})")
      people = PEOPLE.to_h do |name, email|
        [email, DemoPerson.find_or_create_by!(email: email) { |person| person.name = name }]
      end

      launch = DemoProject.find_by(name: LAUNCH)
      unless launch
        launch = DemoProject.create!(name: LAUNCH)
        MEMBERSHIPS.each_with_index do |(email, role), index|
          launch.project_people.create!(person: people.fetch(email), role: role, position: index + 1)
        end
      end

      DemoProject.find_or_create_by!(name: EMPTY)
    end
  end

  def self.launch
    ensure!
    DemoProject.find_by!(name: LAUNCH)
  end

  def self.empty
    ensure!
    DemoProject.find_by!(name: EMPTY)
  end

  def self.item(person)
    {id: person.id.to_s, title: person.name, description: person.email}
  end

  def self.apply_submitted_order!(project, attributes)
    return if attributes.blank?

    existing = project.project_people.select(&:persisted?).index_by { |row| row.id.to_s }
    fresh = project.project_people.reject(&:persisted?)
    cursor = 0
    ordered = []

    attributes.each_value do |attrs|
      values = attrs.to_h.stringify_keys
      next if ActiveModel::Type::Boolean.new.cast(values["_destroy"])
      next if values["id"].blank? && values["person_id"].blank? && values["role"].blank?

      if values["id"].present?
        row = existing[values["id"].to_s]
      else
        row = fresh[cursor]
        cursor += 1
      end

      ordered << row if row
    end

    ordered.each_with_index do |row, index|
      row.position = index + 1
    end
  end

  def self.reorder!(project:, moving_id:, target_position:)
    unless moving_id.to_s.match?(/\A\d+\z/) && target_position.to_s.match?(/\A\d+\z/)
      return {ok: true, skipped: true}
    end

    rows = project.project_people.order(:position, :id).to_a
    moving = rows.find { |row| row.id == moving_id.to_i }
    return {ok: true, skipped: true} unless moving

    rows.delete(moving)
    index = target_position.to_i - 1
    index = 0 if index.negative?
    index = rows.length if index > rows.length
    rows.insert(index, moving)
    items = rows.each_with_index.map { |row, position| {id: row.id, position: position + 1} }

    Ordering::ReorderService.call(
      relation: project.project_people,
      items: items,
      strategy: "dense_integer"
    )
  end
end
