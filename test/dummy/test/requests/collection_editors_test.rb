# frozen_string_literal: true

require "test_helper"

class CollectionEditorsTest < ActionDispatch::IntegrationTest
  setup do
    CollectionEditorDemo.ensure!
  end

  test "show renders people, join roles, nested fields, and the empty collection" do
    get demo_collection_editor_path

    assert_response :success
    assert_includes response.body, "Alice Chen"
    assert_includes response.body, "alice@example.com"
    assert_includes response.body, "Daniel Lee"
    assert_includes response.body, "Priya Shah"
    assert_includes response.body, "Designer"
    assert_includes response.body, "Photographer"
    assert_includes response.body, "Producer"
    assert_includes response.body, ">Row<"
    refute_includes response.body, ">Collaborator<"
    refute_includes response.body, "Add collaborator"
    assert_match(/class="[^"]*\bflat-pack-select\b[^"]*\bborder-0\b/, response.body)
    assert_match(/class="[^"]*\bflat-pack-input-wrapper\b[^"]*\bflat-pack-select-wrapper\b/, response.body)
    assert_match(/name="name"[^>]*border-\[var\(--surface-border-color\)\]|border-\[var\(--surface-border-color\)\][^>]*name="name"/, response.body)
    assert_includes response.body, "No collaborators yet"
    assert_includes response.body, "bg-[var(--color-secondary)]"
    assert_includes response.body, "data-collection-editor-chip-remove"
    refute_includes response.body, "flat-pack-collection-editor-edit"
    refute_includes response.body, "flat-pack-collection-editor-change"
    refute_includes response.body, "flat-pack-collection-editor-create\""
    assert_includes response.body, "New Person"
    assert_includes response.body, 'role="dialog"'
    assert_includes response.body, 'data-collection-editor-create-modal="true"'
    assert_includes response.body, 'data-collection-editor-create-submit="true"'
    assert_includes response.body, "max-w-sm"
    assert_includes response.body, "Reorder Alice Chen"
    assert_includes response.body, "Remove Alice Chen"
    assert_includes response.body, "Edit Alice Chen"
    assert_includes response.body, 'data-update-url="/demo/collection_editor/people/:id"'
    assert_includes response.body, "Edit Person"
    assert_includes response.body, "demo_project[project_people_attributes]"
    assert_includes response.body, "[person_id]"
    assert_includes response.body, "[role]"
    assert_includes response.body, "[_destroy]"
    assert_includes response.body, "NEW_RECORD"
    assert_includes response.body, 'data-orderable-unsaved="true"'
    assert_includes response.body, "moving_recording_id"
    assert_includes response.body, "target_position"
    assert_includes response.body, "collection-editor-token-override"
    assert_includes response.body, "--collection-editor-title-color"
    assert_includes response.body, "Text fields"
    assert_includes response.body, "Single-line text in each cell."
    refute_includes response.body, ">Line<"
    assert_includes response.body, "No lines yet"
    assert_includes response.body, "Cold open"
    assert_includes response.body, "Studio wide"
    assert_includes response.body, "Hold two seconds"
    assert_includes response.body, "Host close-up"
    assert_includes response.body, "Name lower third"
    assert_includes response.body, "End card"
    assert_includes response.body, "Fade out"
    assert_includes response.body, "Remove Cold open"
    assert_includes response.body, 'name="lines[1][item]"'
    assert_includes response.body, 'name="lines[2][detail]"'
    assert_includes response.body, 'name="lines[3][note]"'
    assert_match(/name="lines\[1\]\[item\]"[^>]*\bborder-0\b|\bborder-0\b[^>]*name="lines\[1\]\[item\]"/, response.body)
    refute_includes response.body, "Alice Chen-Smith"

    get "/themes"
    assert_response :success
    assert_includes response.body, "collection-editor-token-override"
    assert_includes response.body, "Alice Chen"
    assert_includes response.body, "--collection-editor-title-color"
  end

  test "search returns primary and secondary text for name or email" do
    get demo_collection_editor_people_path, params: {q: "alice"}, as: :json

    assert_response :success
    titles = json.fetch("items").map { |item| item.fetch("title") }
    assert_includes titles, "Alice Chen"
    assert_includes titles, "Alice Chen-Smith"
    refute_includes titles, "Daniel Lee"
    alice = json.fetch("items").find { |item| item.fetch("title") == "Alice Chen" }
    assert_equal "alice@example.com", alice.fetch("description")

    get demo_collection_editor_people_path, params: {q: "studio"}, as: :json
    assert_equal ["Alice Chen-Smith"], json.fetch("items").map { |item| item.fetch("title") }
  end

  test "create failure returns errors and does not attach a person" do
    assert_no_difference "DemoPerson.count" do
      post demo_collection_editor_people_path, params: {name: "Morgan Patel", email: ""}, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal false, json.fetch("ok")
    assert json.fetch("errors").any? { |message| message.include?("Email") }
    assert_equal 0, DemoProjectPerson.joins(:person).where(demo_people: {name: "Morgan Patel"}).count
  end

  test "create success returns the person id and summary" do
    assert_difference "DemoPerson.count", 1 do
      post demo_collection_editor_people_path, params: {name: "Morgan Patel", email: "morgan@example.com"}, as: :json
    end

    assert_response :success
    item = json.fetch("item")
    assert_equal "Morgan Patel", item.fetch("title")
    assert_equal "morgan@example.com", item.fetch("description")
    assert DemoPerson.exists?(id: item.fetch("id"), email: "morgan@example.com")
    assert_not DemoProjectPerson.exists?(person_id: item.fetch("id"))
  end

  test "show person returns the fields for the edit modal" do
    person = DemoPerson.find_by!(email: "alice@example.com")

    get demo_collection_editor_person_path(person), as: :json

    assert_response :success
    assert_equal person.id.to_s, json.dig("item", "id")
    assert_equal "Alice Chen", json.dig("fields", "name")
    assert_equal "alice@example.com", json.dig("fields", "email")
  end

  test "update person returns the new summary and keeps the role" do
    project = CollectionEditorDemo.launch
    membership = membership_for(project, "alice@example.com")
    person = membership.person

    patch demo_collection_editor_person_path(person), params: {name: "Alice Chen-Smith", email: "alice@example.com"}, as: :json

    assert_response :success
    assert_equal true, json.fetch("ok")
    assert_equal "Alice Chen-Smith", json.dig("item", "title")
    assert_equal "alice@example.com", person.reload.email
    assert_equal "Alice Chen-Smith", person.name
    assert_equal "alice@studio.example", DemoPerson.find_by!(name: "Alice Chen-Smith", email: "alice@studio.example").email
    assert_equal "Designer", membership.reload.role
  end

  test "update person returns validation errors" do
    person = DemoPerson.find_by!(email: "alice@example.com")

    patch demo_collection_editor_person_path(person), params: {name: "Alice Chen", email: "not-an-email"}, as: :json

    assert_response :unprocessable_entity
    assert_equal false, json.fetch("ok")
    assert json.fetch("errors").any? { |message| message.include?("Email") }
    assert_equal "alice@example.com", person.reload.email
  end

  test "html person update still redirects" do
    person = DemoPerson.find_by!(email: "alice@example.com")

    patch demo_collection_editor_person_path(person), params: {demo_person: {name: person.name, email: person.email}}

    assert_redirected_to demo_collection_editor_path
  end

  test "removing a row destroys the relationship and keeps the person" do
    project = CollectionEditorDemo.launch
    membership = membership_for(project, "alice@example.com")
    person = membership.person

    patch demo_collection_editor_project_path(project), params: {
      demo_project: {
        name: project.name,
        project_people_attributes: membership_attributes(project).merge(
          membership.id.to_s => {id: membership.id, person_id: person.id, role: "Designer", _destroy: "1"}
        )
      }
    }

    assert_redirected_to demo_collection_editor_path
    assert_not DemoProjectPerson.exists?(membership.id)
    assert DemoPerson.exists?(person.id)
  end

  test "a new nested row saves the person id, role, and submitted order" do
    project = CollectionEditorDemo.launch
    person = DemoPerson.find_by!(email: "alice@studio.example")

    patch demo_collection_editor_project_path(project), params: {
      demo_project: {
        name: project.name,
        project_people_attributes: membership_attributes(project).merge(
          "987654321" => {person_id: person.id, role: "Editor"}
        )
      }
    }

    assert_redirected_to demo_collection_editor_path
    membership = project.project_people.find_by!(person: person)
    assert_equal "Editor", membership.role
    assert_equal project.project_people.maximum(:position), membership.position
  end

  test "a blank role re-renders the new row and does not save it" do
    project = CollectionEditorDemo.launch
    person = DemoPerson.find_by!(email: "alice@studio.example")

    patch demo_collection_editor_project_path(project), params: {
      demo_project: {
        name: project.name,
        project_people_attributes: membership_attributes(project).merge(
          "987654322" => {person_id: person.id, role: ""}
        )
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "Alice Chen-Smith"
    assert_includes response.body, "alice@studio.example"
    assert_match(/can(?:'|&#39;)t be blank/, response.body)
    assert_match(/name="demo_project\[project_people_attributes\]\[\d+\]\[person_id\]"/, response.body)
    assert_includes response.body, %(value="#{person.id}")
    assert_not project.project_people.exists?(person: person)
  end

  test "adding a person who is already a collaborator keeps the row and the person" do
    project = CollectionEditorDemo.launch
    person = DemoPerson.find_by!(email: "alice@example.com")

    assert_no_difference "DemoProjectPerson.count" do
      patch demo_collection_editor_project_path(project), params: {
        demo_project: {
          name: project.name,
          project_people_attributes: membership_attributes(project).merge(
            "987654323" => {person_id: person.id, role: "Editor"}
          )
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "already a collaborator"
    assert_equal 1, project.project_people.where(person: person).count
  end

  test "editing a person does not change the relationship role" do
    person = DemoPerson.find_by!(email: "alice@example.com")

    patch demo_collection_editor_person_path(person), params: {
      demo_person: {name: "Alice C.", email: "alice@example.com"}
    }

    assert_redirected_to demo_collection_editor_path
    follow_redirect!
    assert_includes response.body, "Alice C."
    membership = CollectionEditorDemo.launch.project_people.find_by!(person: person.reload)
    assert_equal "Designer", membership.role
    assert_equal "alice@example.com", person.email
  end

  test "reorder uses moving_recording_id and target_position" do
    project = CollectionEditorDemo.launch
    moving = membership_for(project, "priya@example.com")

    patch demo_reorder_collection_editor_path(project), params: {
      moving_recording_id: moving.id,
      target_position: 1
    }, as: :json

    assert_response :success
    assert_equal true, json.fetch("ok")
    ordered = project.project_people.reload.map { |row| row.person.email }
    assert_equal ["priya@example.com", "alice@example.com", "daniel@example.com"], ordered
    assert_equal [1, 2, 3], project.project_people.order(:position, :id).pluck(:position)
  end

  test "an unsaved row id does not change persisted order" do
    project = CollectionEditorDemo.launch
    before = project.project_people.order(:position, :id).pluck(:id)

    patch demo_reorder_collection_editor_path(project), params: {
      moving_recording_id: "new_abc",
      target_position: 1
    }, as: :json

    assert_response :success
    assert_equal true, json.fetch("ok")
    assert_equal true, json.fetch("skipped")
    assert_equal before, project.project_people.order(:position, :id).pluck(:id)
  end

  test "gallery joins a library image and leaves the file in the library" do
    project = CollectionEditorDemo.launch

    get demo_collection_editor_path

    assert_response :success
    assert_includes response.body, "North window"
    assert_includes response.body, "Opening still"
    assert_includes response.body, "On the bench"
    assert_includes response.body, "Ada Lorne"
    assert_includes response.body, "Jules Park"
    assert_includes response.body, "Choose image"
    assert_includes response.body, 'data-collection-editor-image="true"'
    assert_includes response.body, 'data-search-url="/demo/collection_editor/images"'
    assert_includes response.body, 'data-update-url="/demo/collection_editor/images/:id"'
    assert_includes response.body, "[image_id]"
    assert_includes response.body, "[caption]"
    assert_includes response.body, "[credit]"
    assert_includes response.body, 'data-collection-editor-library-modal="true"'
    assert_includes response.body, "Save gallery"
    assert_includes response.body, "Edit North window"
    assert_includes response.body, "--collection-editor-columns: auto max-content minmax(8rem, 1fr) minmax(8rem, 1fr) auto"
    assert_includes response.body, "--collection-editor-columns: auto minmax(0, 1.4fr) minmax(8rem, 1fr) auto"

    get demo_collection_editor_images_path, params: {q: "lens"}, as: :json

    assert_response :success
    lens_item = json.fetch("items").find { |item| item.fetch("title") == "Lens" }
    assert lens_item.fetch("thumbnail_url").start_with?("data:image/svg+xml")

    assert_difference -> { DemoImage.count }, 1 do
      post demo_collection_editor_images_path, params: {name: "Gate", alt_text: "The front gate"}, as: :json
    end
    assert_response :success
    created = json.fetch("item")
    assert_equal "Gate", created.fetch("title")
    assert created.fetch("thumbnail_url").present?

    post demo_collection_editor_images_path, params: {name: "", alt_text: ""}, as: :json
    assert_response :unprocessable_entity

    image = DemoImage.find(created.fetch("id"))
    get demo_collection_editor_image_path(image), as: :json
    assert_response :success
    assert_equal "Gate", json.dig("fields", "name")
    assert_equal "The front gate", json.dig("fields", "alt_text")

    patch demo_collection_editor_image_path(image), params: {name: "Front gate", alt_text: "The front gate"}, as: :json
    assert_response :success
    assert_equal "Front gate", json.dig("item", "title")
    assert json.dig("item", "thumbnail_url").present?
    assert_equal "Front gate", image.reload.name

    lens = DemoImage.find_by!(name: "Lens")
    attributes = gallery_attributes(project)
    attributes["99"] = {image_id: lens.id, caption: "Spare lens", credit: "Jules Park"}

    assert_difference -> { DemoProjectImage.where(project_id: project.id).count }, 1 do
      patch demo_collection_editor_gallery_path(project), params: {demo_project: {gallery_images_attributes: attributes}}
    end
    assert_redirected_to demo_collection_editor_path
    join = project.gallery_images.find_by!(image: lens)
    assert_equal "Spare lens", join.caption
    assert_equal "Jules Park", join.credit
    assert_equal 4, join.position
    assert DemoImage.exists?(lens.id)

    slate = project.gallery_images.joins(:image).find_by!(demo_images: {name: "Slate"})
    slate_image_id = slate.image_id
    removed = gallery_attributes(project)
    removed[slate.id.to_s] = {id: slate.id, image_id: slate.image_id, caption: slate.caption, credit: slate.credit, _destroy: "1"}
    patch demo_collection_editor_gallery_path(project), params: {demo_project: {gallery_images_attributes: removed}}
    assert_redirected_to demo_collection_editor_path
    assert_not DemoProjectImage.exists?(slate.id)
    assert DemoImage.exists?(slate_image_id)

    north = DemoImage.find_by!(name: "North window")
    duplicate = gallery_attributes(project)
    duplicate["100"] = {image_id: north.id, caption: "Again", credit: "Ada Lorne"}
    assert_no_difference -> { DemoProjectImage.where(project_id: project.id).count } do
      patch demo_collection_editor_gallery_path(project), params: {demo_project: {gallery_images_attributes: duplicate}}
    end
    assert_response :unprocessable_entity
    assert_includes response.body, "already on this page"
  end

  test "gallery reorder uses moving_recording_id and target_position" do
    project = CollectionEditorDemo.launch
    moving = project.gallery_images.joins(:image).find_by!(demo_images: {name: "Slate"})

    patch demo_reorder_collection_editor_gallery_path(project), params: {
      moving_recording_id: moving.id,
      target_position: 1
    }, as: :json

    assert_response :success
    assert_equal true, json.fetch("ok")
    names = project.gallery_images.reload.order(:position, :id).map { |row| row.image.name }
    assert_equal ["Slate", "North window", "Reel can"], names
    assert_equal [1, 2, 3], project.gallery_images.order(:position, :id).pluck(:position)
  end

  private

  def json
    JSON.parse(response.body)
  end

  def membership_for(project, email)
    project.project_people.joins(:person).find_by!(demo_people: {email: email})
  end

  def gallery_attributes(project)
    project.gallery_images.reload.order(:position, :id).each_with_object({}) do |join, attributes|
      attributes[join.id.to_s] = {
        id: join.id,
        image_id: join.image_id,
        caption: join.caption,
        credit: join.credit,
        _destroy: "0"
      }
    end
  end

  def membership_attributes(project)
    project.project_people.order(:position, :id).each_with_object({}) do |membership, attributes|
      attributes[membership.id.to_s] = {
        id: membership.id,
        person_id: membership.person_id,
        role: membership.role,
        _destroy: "0"
      }
    end
  end
end
