# frozen_string_literal: true

# Demo pages talk to Postgres when it is there. A refused connection or a
# missing table should render the page. Other statement errors stay loud.
module DemoDatabase
  def self.table_ready?(model)
    availability(model) == :ready
  end

  # :ready, :missing, or :down.
  def self.availability(model)
    model.table_exists? ? :ready : :missing
  rescue ActiveRecord::ActiveRecordError => error
    raise unless handled?(error)

    report!(error)
    error.is_a?(ActiveRecord::StatementInvalid) ? :missing : :down
  end

  def self.handled?(error)
    case error
    when ActiveRecord::ConnectionNotEstablished, ActiveRecord::NoDatabaseError
      true
    when ActiveRecord::StatementInvalid
      undefined_table?(error)
    else
      false
    end
  end

  def self.suppress(error)
    return false unless handled?(error)

    report!(error)
    true
  end

  def self.report!(error)
    Rails.logger.warn("[demo database] #{error.class}: #{error.message}")
    return unless Rails.respond_to?(:error) && Rails.error.respond_to?(:report)

    Rails.error.report(error, handled: true, severity: :warning, source: "demo_database")
  end

  def self.undefined_table?(error)
    cause = error.cause
    return true if defined?(PG::UndefinedTable) && cause.is_a?(PG::UndefinedTable)

    message = "#{error.message} #{cause&.message}"
    message.match?(/undefined table|relation .+ does not exist/i)
  end
  private_class_method :undefined_table?
end
