# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Search
    class CollapseTest < ActiveSupport::TestCase
      test "off is the default posture" do
        posture = Collapse.resolve(collapsible: false, collapsed: true, grow: :end, value: nil)

        assert_instance_of Collapse::Off, posture
        refute posture.active?
      end

      test "collapsible starts collapsed" do
        posture = Collapse.resolve(collapsible: true, collapsed: true, grow: :end, value: nil)

        assert posture.active?
        assert posture.collapsed?
        assert_equal :end, posture.grow
      end

      test "collapsed false starts expanded" do
        posture = Collapse.resolve(collapsible: true, collapsed: false, grow: :start, value: nil)

        refute posture.collapsed?
        assert_equal :start, posture.grow
      end

      test "a value cannot resolve collapsed" do
        posture = Collapse.resolve(collapsible: true, collapsed: true, grow: :end, value: "lamps")

        refute posture.collapsed?
      end

      test "blank value can collapse" do
        posture = Collapse.resolve(collapsible: true, collapsed: true, grow: :end, value: "  ")

        assert posture.collapsed?
      end

      test "invalid collapsible raises" do
        error = assert_raises(ArgumentError) do
          Collapse.resolve(collapsible: "yes", collapsed: true, grow: :end, value: nil)
        end

        assert_match "Invalid collapsible", error.message
      end

      test "invalid grow raises" do
        error = assert_raises(ArgumentError) do
          Collapse.resolve(collapsible: true, collapsed: true, grow: :left, value: nil)
        end

        assert_match "Invalid grow", error.message
      end

      test "grow without the feature still validates" do
        assert_raises(ArgumentError) do
          Collapse.resolve(collapsible: false, collapsed: true, grow: :up, value: nil)
        end
      end
    end
  end
end
