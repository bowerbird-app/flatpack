# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

module FlatPack
  class RadiusLanguageAuditorTest < ActiveSupport::TestCase
    test "reports leftover Tailwind radius scale utilities" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app/components"))
        File.write(File.join(dir, "app/components/example.rb"), %(class: "rounded-md rounded-full"))

        result = RadiusLanguageAuditor.new(engine_root: dir).call

        refute_predicate result, :success?
        assert_equal ["rounded-md"], result.violations.first.utilities
      end
    end

    test "passes when kit files use tokenized radius classes" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir, "app/components"))
        File.write(File.join(dir, "app/components/example.rb"), %(class: "rounded-[var(--radius-md)] rounded-full"))

        result = RadiusLanguageAuditor.new(engine_root: dir).call

        assert_predicate result, :success?
      end
    end

    test "kit components and javascript do not use Tailwind radius scale names" do
      result = RadiusLanguageAuditor.new.call

      assert_predicate result, :success?, lambda {
        result.violations.map { |violation| "#{violation.path}: #{violation.utilities.join(", ")}" }.join("\n")
      }
    end
  end
end
