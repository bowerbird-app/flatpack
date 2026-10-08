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

  SWATCHES = %w[#8aa2a5 #c4a574 #5c6b73 #7d8b6a #6b5b7a #a67c6d].freeze

  IMAGES = [
    ["North window", "A north-facing window", "#8aa2a5"],
    ["Reel can", "A film can on a bench", "#c4a574"],
    ["Slate", "A clapperboard before the take", "#5c6b73"],
    ["Lens", "A camera lens", "#7d8b6a"],
    ["Night set", "A set after dark", "#6b5b7a"],
    ["Still frame", "A held frame", "#a67c6d"]
  ].freeze

  JOINS = [
    ["North window", "Opening still", "Ada Lorne"],
    ["Reel can", "On the bench", "Jules Park"],
    ["Slate", "Before the take", "Ada Lorne"]
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

      seed_gallery!(launch)
      DemoProject.find_or_create_by!(name: EMPTY)
    end
  end

  def self.seed_gallery!(project)
    return if project.gallery_images.exists?

    images = IMAGES.to_h do |name, alt_text, swatch|
      record = DemoImage.find_or_create_by!(name: name) do |image|
        image.alt_text = alt_text
        image.swatch = swatch
      end
      [name, record]
    end

    JOINS.each_with_index do |(name, caption, credit), index|
      project.gallery_images.create!(
        image: images.fetch(name),
        caption: caption,
        credit: credit,
        position: index + 1
      )
    end
  end

  def self.assign_swatch(image)
    return if image.swatch.present?

    image.swatch = SWATCHES[DemoImage.count % SWATCHES.length]
  end

  def self.thumbnail_data_uri(image)
    swatch = SWATCHES.include?(image.swatch) ? image.swatch : SWATCHES.first
    initials = image.name.to_s.split.filter_map { |word| word[0] }.join.first(2).upcase
    escaped = ERB::Util.html_escape(initials)
    svg = %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80"><rect width="80" height="80" fill="#{swatch}"/><text x="40" y="46" text-anchor="middle" font-family="sans-serif" font-size="24" fill="#ffffff">#{escaped}</text></svg>)
    "data:image/svg+xml,#{ERB::Util.url_encode(svg)}"
  end

  def self.image_item(image)
    {
      id: image.id.to_s,
      title: image.name,
      description: image.alt_text,
      thumbnail_url: thumbnail_data_uri(image)
    }
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

  def self.apply_gallery_order!(project, attributes)
    return if attributes.blank?

    existing = project.gallery_images.select(&:persisted?).index_by { |row| row.id.to_s }
    fresh = project.gallery_images.reject(&:persisted?)
    cursor = 0
    ordered = []

    attributes.each_value do |attrs|
      values = attrs.to_h.stringify_keys
      next if ActiveModel::Type::Boolean.new.cast(values["_destroy"])
      next if values["id"].blank? && values["image_id"].blank? && values["caption"].blank? && values["credit"].blank?

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

  def self.reorder_gallery!(project:, moving_id:, target_position:)
    unless moving_id.to_s.match?(/\A\d+\z/) && target_position.to_s.match?(/\A\d+\z/)
      return {ok: true, skipped: true}
    end

    rows = project.gallery_images.order(:position, :id).to_a
    moving = rows.find { |row| row.id == moving_id.to_i }
    return {ok: true, skipped: true} unless moving

    rows.delete(moving)
    index = target_position.to_i - 1
    index = 0 if index.negative?
    index = rows.length if index > rows.length
    rows.insert(index, moving)
    items = rows.each_with_index.map { |row, position| {id: row.id, position: position + 1} }

    Ordering::ReorderService.call(
      relation: project.gallery_images,
      items: items,
      strategy: "dense_integer"
    )
  end
end
