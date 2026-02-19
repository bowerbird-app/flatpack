# frozen_string_literal: true

module Ordering
  class ReorderService
    class InvalidPayload < StandardError; end

    Result = Struct.new(:ok, :status, :error, :strategy, :items, :version, keyword_init: true)

    def self.call(...)
      new(...).call
    end

    def initialize(relation:, items:, strategy:, version: nil)
      @relation = relation
      @items = items
      @strategy_key = strategy.to_s.presence || "dense_integer"
      @version = version
    end

    def call
      normalized = normalize_items!(@items)
      result = nil

      ActiveRecord::Base.transaction do
        records = @relation.lock.order(:position, :id).to_a
        raise ActiveRecord::Rollback if records.empty?

        result = conflict_result if stale_version?(records)
        raise ActiveRecord::Rollback if result

        strategy.apply!(records: records, items: normalized)

        reloaded = @relation.order(:position, :id)
        result = Result.new(
          ok: true,
          status: :ok,
          strategy: @strategy_key,
          items: reloaded.map { |row| {id: row.id, position: row.position} },
          version: current_version(reloaded)
        ).to_h
      end

      result || Result.new(ok: false, status: :not_found, error: "No records found").to_h
    rescue InvalidPayload => e
      Result.new(ok: false, status: :unprocessable_entity, error: e.message).to_h
    rescue => e
      Result.new(ok: false, status: :internal_server_error, error: e.message).to_h
    end

    private

    def strategy
      @strategy ||= case @strategy_key
      when "dense_integer"
        Strategies::DenseInteger.new
      else
        raise InvalidPayload, "Unsupported strategy: #{@strategy_key}"
      end
    end

    def normalize_items!(items)
      unless items.is_a?(Array) && items.any?
        raise InvalidPayload, "Items must be a non-empty array"
      end

      items.map do |item|
        id = item[:id] || item["id"]
        position = item[:position] || item["position"]

        raise InvalidPayload, "Each item must include id and position" unless id && position

        {id: Integer(id), position: Integer(position)}
      end
    rescue ArgumentError
      raise InvalidPayload, "Item id and position must be integers"
    end

    def stale_version?(records)
      return false if @version.blank?

      current_version(records) != @version.to_s
    end

    def conflict_result
      Result.new(ok: false, status: :conflict, error: "Order is stale. Reload and retry.").to_h
    end

    def current_version(records)
      latest = if records.respond_to?(:maximum)
        records.maximum(:updated_at)
      else
        records.filter_map(&:updated_at).max
      end

      latest&.to_f&.to_s || "0"
    end

    module Strategies
      class DenseInteger
        def apply!(records:, items:)
          records_by_id = records.index_by(&:id)

          desired_ids = items
            .sort_by { |item| item[:position] }
            .map { |item| item[:id] }
            .select { |id| records_by_id.key?(id) }

          existing_ids = records.map(&:id)
          final_ids = desired_ids + (existing_ids - desired_ids)
          offset = final_ids.size + 1000

          final_ids.each_with_index do |id, index|
            row = records_by_id[id]
            row.update!(position: offset + index)
          end

          final_ids.each_with_index do |id, index|
            row = records_by_id[id]
            row.update!(position: index + 1)
          end
        end
      end
    end
  end
end
