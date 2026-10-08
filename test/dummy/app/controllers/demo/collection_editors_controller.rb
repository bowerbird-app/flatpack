# frozen_string_literal: true

module Demo
  class CollectionEditorsController < ApplicationController
    before_action :ensure_demo
    before_action :load_previews, only: [:show, :update]

    def show
      @project = CollectionEditorDemo.launch
      @empty_project = CollectionEditorDemo.empty
    end

    def update
      @project = CollectionEditorDemo.launch
      @empty_project = CollectionEditorDemo.empty
      target = [@project, @empty_project].find { |record| record.id == params[:id].to_i } || DemoProject.find(params[:id])
      attributes = project_params
      target.assign_attributes(attributes)
      CollectionEditorDemo.apply_submitted_order!(target, attributes[:project_people_attributes])

      if target.save
        redirect_to demo_collection_editor_path, notice: "Collaborators saved."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def search_people
      query = params[:q].to_s.strip
      people = DemoPerson.order(:name, :id)
      if query.present?
        escaped = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
        people = people.where("name ILIKE :query OR email ILIKE :query", query: escaped)
      end

      render json: {items: people.limit(20).map { |person| CollectionEditorDemo.item(person) }}
    end

    def create_person
      person = DemoPerson.new(params.permit(:name, :email))
      if person.save
        render json: {ok: true, item: CollectionEditorDemo.item(person)}
      else
        render json: {ok: false, errors: person.errors.full_messages}, status: :unprocessable_entity
      end
    end

    def show_person
      person = DemoPerson.find(params[:id])
      render json: {item: CollectionEditorDemo.item(person), fields: person_fields(person)}
    end

    def edit_person
      @person = DemoPerson.find(params[:id])
    end

    def update_person
      @person = DemoPerson.find(params[:id])
      attributes = json_person? ? params.permit(:name, :email) : params.require(:demo_person).permit(:name, :email)
      saved = @person.update(attributes)

      if json_person?
        if saved
          render json: {ok: true, item: CollectionEditorDemo.item(@person)}
        else
          render json: {ok: false, errors: @person.errors.full_messages}, status: :unprocessable_entity
        end
      elsif saved
        redirect_to demo_collection_editor_path, notice: "Person saved. The project role was not changed."
      else
        render :edit_person, status: :unprocessable_entity
      end
    end

    def reorder
      result = CollectionEditorDemo.reorder!(
        project: DemoProject.find(params[:id]),
        moving_id: params[:moving_recording_id],
        target_position: params[:target_position]
      )
      status = result[:ok] ? :ok : (result[:status] || :unprocessable_entity)
      render json: {ok: result[:ok], skipped: result[:skipped], items: result[:items]}.compact, status: status
    end

    private

    def ensure_demo
      CollectionEditorDemo.ensure!
    end

    def load_previews
      @collection_preview = CollectionEditorPreview.new(id: 1, person_id: 1, role: "Designer")
      @collection_blank = CollectionEditorPreview.new
      @text_lines = [
        CollectionEditorTextLine.new(item: "Cold open", detail: "Studio wide", note: "Hold two seconds"),
        CollectionEditorTextLine.new(item: "Interview", detail: "Host close-up", note: "Name lower third"),
        CollectionEditorTextLine.new(item: "End card", detail: "Logo", note: "Fade out")
      ]
    end

    def project_params
      params.require(:demo_project).permit(:name, project_people_attributes: [:id, :person_id, :role, :_destroy])
    end

    def json_person?
      request.format.json?
    end

    def person_fields(person)
      {name: person.name, email: person.email}
    end
  end
end
