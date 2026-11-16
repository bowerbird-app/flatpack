# frozen_string_literal: true

# Recording Studio 7 dropped recording_studio_page_nav. Host views that still
# call it map the old kwargs onto Flatpack's page nav.
module DummyRecordingStudioPageNavHelper
  def recording_studio_page_nav(title: nil, page_nav_back_url: nil, page_nav_back_label: nil,
    page_nav_anchor_url: nil, page_nav_anchor_label: nil, **)
    content_for(:title, title) if title.present?

    kwargs = {round: true, style: :default}
    kwargs[:back_href] = page_nav_back_url if page_nav_back_url.present?
    kwargs[:back_tooltip] = page_nav_back_label if page_nav_back_label.present?
    kwargs[:anchor_href] = page_nav_anchor_url if page_nav_anchor_url.present?
    kwargs[:anchor_tooltip] = page_nav_anchor_label if page_nav_anchor_label.present?
    flat_pack_page_nav(**kwargs)
  end

  def dummy_studio_recording_tree_path
    Rails.application.routes.url_helpers.studio_recording_tree_path
  end

  def dummy_destroy_user_session_path
    Rails.application.routes.url_helpers.destroy_user_session_path
  end

  def dummy_new_user_session_path
    Rails.application.routes.url_helpers.new_user_session_path
  end

  def dummy_oauth_connected_apps_path
    RecordingStudioOauth::Engine.routes.url_helpers.connected_apps_path(
      script_name: "/recording_studio_oauth"
    )
  end
end
