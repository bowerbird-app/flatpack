# frozen_string_literal: true

class GalleryEditorController < ApplicationController
  layout false

  before_action :maybe_delay

  def gallery
  end

  def edit
    @image = GalleryEditorDemo.image(params[:id])
    return head :not_found unless @image

    @photographer = GalleryEditorDemo.photographer(@image.fetch(:photographer_id))
  end

  def photographer
    @image = GalleryEditorDemo.image(params[:id])
    return head :not_found unless @image

    @photographer = GalleryEditorDemo.photographer(@image.fetch(:photographer_id))
  end

  def missing
    head :not_found
  end

  private

  def maybe_delay
    seconds = params[:delay].to_f
    sleep seconds if seconds.positive?
  end
end
