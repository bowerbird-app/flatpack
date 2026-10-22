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

  test "database demo pages render when Postgres is unavailable" do
    pages = {
      "/demo/collection_editor" => "Saved collections need the database",
      "/demo/modal_filter" => "Modal Filter",
      "/demo/tables/basic" => "Basic Table",
      "/demo/tables/sortable" => "Sortable Table",
      "/demo/tables/draggable" => "Draggable Rows",
      "/demo/pagination_infinite" => "Infinite Scroll",
      "/demo/grid/movable_cards" => "Movable cards data unavailable",
      "/demo/comments" => "Comments need the database",
      "/demo/chat/demo" => "Chat needs the database",
      "/demo/articles" => "Articles need the database",
      "/users/sign_in" => "Continue with email"
    }

    with_database_unavailable do
      pages.each do |path, marker|
        get path
        assert_response :success, path
        assert_includes response.body, marker, path
      end
    end
  end
end
