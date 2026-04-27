# frozen_string_literal: true

require "pathname"

module FlatPack
  class InstallVerifier
    CheckResult = Struct.new(:id, :description, :details, :status, keyword_init: true) do
      def pass?
        status == :pass
      end
    end

    Result = Struct.new(:checks, keyword_init: true) do
      def success?
        checks.all?(&:pass?)
      end

      def failures
        checks.reject(&:pass?)
      end
    end

    def initialize(rails_root: Rails.root, contract: FlatPack::InstallContract.data)
      @rails_root = Pathname.new(rails_root)
      @contract = contract
    end

    def call
      checks = verification_checks.map { |check| verify(check) }
      Result.new(checks: checks)
    end

    private

    attr_reader :contract, :rails_root

    def verification_checks
      contract.fetch("verification").fetch("checks")
    end

    def verify(check)
      case check.fetch("type")
      when "file_contains_all"
        verify_file_contains_all(check)
      when "first_existing_file_contains_all"
        verify_first_existing_file_contains_all(check)
      else
        CheckResult.new(
          id: check.fetch("id"),
          description: check.fetch("description"),
          details: "Unsupported verification type: #{check.fetch("type")}",
          status: :fail
        )
      end
    end

    def verify_file_contains_all(check)
      absolute_path = rails_root.join(check.fetch("path"))
      return missing_file_result(check, absolute_path) unless absolute_path.exist?

      content = File.read(absolute_path)
      missing_matches = missing_matches_for(content, check.fetch("matches"))

      if missing_matches.empty?
        passed_result(check, absolute_path, check.fetch("success_message"))
      else
        failed_match_result(check, absolute_path, missing_matches)
      end
    end

    def verify_first_existing_file_contains_all(check)
      relative_paths = check.fetch("paths")
      absolute_paths = relative_paths.map { |relative_path| rails_root.join(relative_path) }
      existing_path = absolute_paths.find(&:exist?)

      unless existing_path
        return CheckResult.new(
          id: check.fetch("id"),
          description: check.fetch("description"),
          details: "None of the expected files exist: #{relative_paths.join(", ")}",
          status: :fail
        )
      end

      content = File.read(existing_path)
      missing_matches = missing_matches_for(content, check.fetch("matches"))

      if missing_matches.empty?
        passed_result(check, existing_path, check.fetch("success_message"))
      else
        failed_match_result(check, existing_path, missing_matches)
      end
    end

    def missing_matches_for(content, matches)
      matches.reject { |match| content.include?(match) }
    end

    def missing_file_result(check, absolute_path)
      CheckResult.new(
        id: check.fetch("id"),
        description: check.fetch("description"),
        details: "Missing file: #{relative_to_root(absolute_path)}",
        status: :fail
      )
    end

    def failed_match_result(check, absolute_path, missing_matches)
      CheckResult.new(
        id: check.fetch("id"),
        description: check.fetch("description"),
        details: "#{relative_to_root(absolute_path)} is missing: #{missing_matches.join(" | ")}",
        status: :fail
      )
    end

    def passed_result(check, absolute_path, success_message)
      details = success_message || "Verified #{relative_to_root(absolute_path)}"

      CheckResult.new(
        id: check.fetch("id"),
        description: check.fetch("description"),
        details: details,
        status: :pass
      )
    end

    def relative_to_root(path)
      Pathname.new(path).relative_path_from(rails_root).to_s
    end
  end
end
