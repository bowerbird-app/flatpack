# frozen_string_literal: true

# Handles image uploads for the rich text editor toolbar.
# Accepts a multipart POST with a single `file` param, stores it via
# ActiveStorage, and returns the blob URL as JSON for immediate insertion.
#
# Only images are accepted. The `Content-Type` is validated server-side;
# the 10 MB size limit is enforced before the file reaches ActiveStorage.
class ArticleImagesController < ApplicationController
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp image/svg+xml].freeze
  MAX_FILE_SIZE = 10.megabytes

  def create
    file = params[:file]

    unless file.is_a?(ActionDispatch::Http::UploadedFile)
      return render json: {error: "No file provided"}, status: :bad_request
    end

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      return render json: {error: "File type not allowed. Accepted: JPEG, PNG, GIF, WebP, SVG"}, status: :unprocessable_entity
    end

    if file.size > MAX_FILE_SIZE
      return render json: {error: "File is too large (max 10 MB)"}, status: :unprocessable_entity
    end

    service_name = Rails.application.config.active_storage.service || :local
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type,
      service_name: service_name
    )

    render json: {url: url_for(blob)}, status: :created
  end
end
