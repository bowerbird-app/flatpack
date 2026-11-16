# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ClassMergerTest < ActiveSupport::TestCase
    SAMPLES = [
      "",
      "   ",
      "px-2 px-4",
      "p-2 px-4 py-1",
      "hover:bg-red-500 bg-blue-500 hover:bg-blue-500",
      "md:px-2 md:px-4",
      "fp-button mt-4 mt-2 !px-2 px-4",
      "block shrink-0 w-5 h-5 -translate-y-0.5"
    ].freeze

    test "reuses one merger" do
      assert_same ClassMerger.merger, ClassMerger.merger
      assert_instance_of TailwindMerge::Merger, ClassMerger.merger
    end

    test "merge matches a fresh merger" do
      SAMPLES.each do |sample|
        assert_equal TailwindMerge::Merger.new.merge(sample), ClassMerger.merge(sample), sample.inspect
      end
    end

    test "concurrent merges match a fresh merger" do
      sample = "px-2 px-4 hover:bg-red-500 bg-blue-500"
      expected = TailwindMerge::Merger.new.merge(sample)
      queues = Array.new(4) { Queue.new }

      threads = queues.map do |queue|
        Thread.new do
          25.times { queue << ClassMerger.merge(sample) }
        end
      end
      threads.each(&:join)

      queues.each do |queue|
        25.times { assert_equal expected, queue.pop }
      end
    end

    test "app components do not construct their own merger" do
      offenders = Dir.glob(FlatPack::Engine.root.join("app/**/*.rb")).select do |path|
        File.read(path).include?("TailwindMerge::Merger.new")
      end

      assert_empty offenders
    end
  end

  class ClassMergerRenderTest < ViewComponent::TestCase
    class Probe < BaseComponent
      def call
        content_tag(:div, "x", **merge_attributes)
      end
    end

    test "a render reuses the shared merger and keeps the winning utility" do
      merger = ClassMerger.merger
      calls = 0
      replaced = false
      TailwindMerge::Merger.define_singleton_method(:new) do |*args, **kwargs, &block|
        calls += 1
        super(*args, **kwargs, &block)
      end
      replaced = true

      render_inline(Probe.new(class: "px-2 px-4"))

      assert_equal 0, calls
      assert_same merger, ClassMerger.merger
      assert_includes rendered_content, "px-4"
      refute_includes rendered_content, "px-2"
    ensure
      TailwindMerge::Merger.singleton_class.remove_method(:new) if replaced
    end
  end
end
