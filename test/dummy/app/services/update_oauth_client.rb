# frozen_string_literal: true

# Updates name and redirect URLs on an existing OauthClient.
# Secret / client id / api key stay fixed after create.
class UpdateOauthClient
  def self.redirect_uris_from_lines(text)
    RecordingStudioOauth::Services::CreateOauthClient.redirect_uris_from_lines(text)
  end

  def self.call(client:, name:, redirect_uris:)
    new(client: client, name: name, redirect_uris: redirect_uris).call
  end

  def initialize(client:, name:, redirect_uris:)
    @client = client
    @name = name.to_s
    @redirect_uris = Array(redirect_uris)
  end

  def call
    return failure("App is revoked") if @client.revoked?

    @client.name = @name
    @client.redirect_uris = @redirect_uris

    if @client.save
      success(@client)
    else
      failure(@client.errors.full_messages.to_sentence)
    end
  end

  Result = Struct.new(:success, :value, :error, keyword_init: true) do
    def success?
      success
    end

    def failure?
      !success
    end
  end

  private

  def success(value)
    Result.new(success: true, value: value, error: nil)
  end

  def failure(message)
    Result.new(success: false, value: nil, error: message)
  end
end
