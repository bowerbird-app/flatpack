# frozen_string_literal: true

# Demo pages talk to Postgres when it is there. A missing database, a refused
# connection, or a missing table should render the page instead of an empty 500.
module DemoDatabase
  ERRORS = [
    ActiveRecord::ConnectionNotEstablished,
    ActiveRecord::NoDatabaseError,
    ActiveRecord::StatementInvalid
  ].freeze

  def self.table_ready?(model)
    model.table_exists?
  rescue *ERRORS
    false
  end
end
