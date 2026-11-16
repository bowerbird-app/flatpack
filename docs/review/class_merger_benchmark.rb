# frozen_string_literal: true

require "benchmark"

ENV["RAILS_ENV"] = "test"
ENV["DB_HOST"] ||= "localhost"
ENV["DB_USER"] ||= "postgres"
ENV["DB_PASSWORD"] ||= "postgres"
ENV["DB_NAME"] ||= "flatpack_dummy_test"

require_relative "../../test/dummy/config/environment"
require "view_component/test_helpers"

class ClassMergerBench
  include ViewComponent::TestHelpers

  EXTRAS = ["mt-2 px-2", "mt-4 px-4", "mt-1 p-2"].freeze

  def view
    @view ||= vc_test_controller.view_context
  end

  def render_set(extra)
    view.render(FlatPack::Card::Component.new(class: "#{extra} p-4"))
    view.render(FlatPack::Shared::IconComponent.new(name: "check", class: extra))
    view.render(FlatPack::Button::Component.new(text: "Save", icon: "check", class: extra))
    view.render(FlatPack::Badge::Component.new(text: "New", class: extra))
  end

  def render_page(page_index)
    extra = EXTRAS[page_index % EXTRAS.size]
    25.times { render_set(extra) }
  end
end

construction_calls = 0
original_new = TailwindMerge::Merger.method(:new)
TailwindMerge::Merger.define_singleton_method(:new) do |*args, **kwargs, &block|
  construction_calls += 1
  original_new.call(*args, **kwargs, &block)
end

bench = ClassMergerBench.new
bench.render_page(0)
construction_calls = 0
GC.start

samples = 5.times.map do
  construction_calls = 0
  GC.start
  seconds = Benchmark.realtime { 20.times { |index| bench.render_page(index) } }
  {seconds: seconds, constructions: construction_calls}
end

merger = TailwindMerge::Merger.new
sample_classes = "inline-flex items-center px-2 px-4 mt-2 mt-4 fp-button"
unique_seconds = Benchmark.realtime do
  2000.times { |index| merger.merge("#{sample_classes} u-#{index}") }
end
repeat_seconds = Benchmark.realtime do
  2000.times { merger.merge(sample_classes) }
end
fresh_seconds = Benchmark.realtime do
  200.times { TailwindMerge::Merger.new.merge(sample_classes) }
end

puts "ruby #{RUBY_VERSION}"
puts "tailwind_merge #{TailwindMerge::VERSION}"
puts "flat_pack #{FlatPack::VERSION}"
puts "page=25x(Card Icon Button Badge) x 20 pages"
samples.each_with_index do |sample, index|
  puts format("sample %d seconds=%.4f constructions=%d", index + 1, sample[:seconds], sample[:constructions])
end
sorted = samples.map { |sample| sample[:seconds] }.sort
median = sorted[sorted.length / 2]
puts format("median_seconds=%.4f min=%.4f max=%.4f", median, sorted.first, sorted.last)
puts format("reused_unique_2000_seconds=%.4f", unique_seconds)
puts format("reused_repeat_2000_seconds=%.4f", repeat_seconds)
puts format("fresh_merger_200_seconds=%.4f", fresh_seconds)
