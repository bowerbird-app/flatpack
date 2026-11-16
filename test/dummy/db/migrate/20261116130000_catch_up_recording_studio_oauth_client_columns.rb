# frozen_string_literal: true

# Recording Studio OAuth shipped these columns on timestamps the dummy had
# already recorded. A fresh schema load will not re-run those files, so the
# host adds the missing client columns and external installs here.
class CatchUpRecordingStudioOauthClientColumns < ActiveRecord::Migration[8.1]
  def up
    add_client_column :use_central_relay, :boolean, null: false, default: false
    add_client_column :allowed_return_patterns, :jsonb, null: false, default: []
    add_client_column :exact_return_urls, :jsonb, null: false, default: []
    add_client_column :allow_registration, :boolean, null: false, default: false
    add_client_column :session_token_provider, :string
    add_client_column :session_token_audience, :string
    add_client_column :session_token_secret_ciphertext, :text
    add_client_column :self_registered, :boolean, null: false, default: false
    add_token_endpoint_auth_method
    create_external_installs
  end

  def down
    drop_table :recording_studio_oauth_external_installs, if_exists: true

    %i[
      token_endpoint_auth_method
      self_registered
      session_token_secret_ciphertext
      session_token_audience
      session_token_provider
      allow_registration
      exact_return_urls
      allowed_return_patterns
      use_central_relay
    ].each do |column|
      remove_column :recording_studio_oauth_clients, column if column_exists?(:recording_studio_oauth_clients, column)
    end
  end

  private

  def add_client_column(name, type, **options)
    return if column_exists?(:recording_studio_oauth_clients, name)

    add_column :recording_studio_oauth_clients, name, type, **options
  end

  def add_token_endpoint_auth_method
    return if column_exists?(:recording_studio_oauth_clients, :token_endpoint_auth_method)

    add_column :recording_studio_oauth_clients, :token_endpoint_auth_method, :string
    execute <<~SQL.squish
      UPDATE recording_studio_oauth_clients
      SET token_endpoint_auth_method = CASE
        WHEN confidential THEN 'client_secret_basic'
        ELSE 'none'
      END
    SQL
    change_column_null :recording_studio_oauth_clients, :token_endpoint_auth_method, false
  end

  def create_external_installs
    return if table_exists?(:recording_studio_oauth_external_installs)

    create_table :recording_studio_oauth_external_installs, id: :uuid do |t|
      t.uuid :oauth_client_id, null: false
      t.string :provider, null: false
      t.string :external_id, null: false
      t.uuid :root_recording_id
      t.string :connected_by_type
      t.uuid :connected_by_id

      t.timestamps
    end

    add_index :recording_studio_oauth_external_installs,
      %i[oauth_client_id provider external_id],
      unique: true,
      name: "index_rs_oauth_external_installs_on_client_provider_external"
    add_index :recording_studio_oauth_external_installs,
      %i[provider external_id],
      name: "index_rs_oauth_external_installs_on_provider_external"
    add_index :recording_studio_oauth_external_installs, :root_recording_id
    add_index :recording_studio_oauth_external_installs,
      %i[connected_by_type connected_by_id],
      name: "index_rs_oauth_external_installs_on_connected_by"

    add_foreign_key :recording_studio_oauth_external_installs,
      :recording_studio_oauth_clients,
      column: :oauth_client_id
    add_foreign_key :recording_studio_oauth_external_installs,
      :recording_studio_recordings,
      column: :root_recording_id
  end
end
