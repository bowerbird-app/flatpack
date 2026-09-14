# frozen_string_literal: true

require "test_helper"

class PublicCatalogWithoutDbTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  module RefuseDatabase
    def lease_connection(*)
      raise ActiveRecord::ConnectionNotEstablished, "simulated PG down"
    end

    def connection(*)
      raise ActiveRecord::ConnectionNotEstablished, "simulated PG down"
    end

    def with_connection(*)
      raise ActiveRecord::ConnectionNotEstablished, "simulated PG down"
    end
  end

  def with_database_unavailable
    db_config = ActiveRecord::Base.connection_db_config
    ActiveRecord::Base.connection_handler.clear_active_connections!
    ActiveRecord::Base.connection_pool.disconnect!
    ActiveRecord::Base.connection_pool.extend(RefuseDatabase)
    yield
  ensure
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(db_config)
  end

  test "GET / succeeds when Postgres is unavailable" do
    with_database_unavailable do
      get "/"
      assert_response :success
    end
  end

  test "GET /demo succeeds when Postgres is unavailable" do
    with_database_unavailable do
      get "/demo"
      assert_response :success
    end
  end
end
