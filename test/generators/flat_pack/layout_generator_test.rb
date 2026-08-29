# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/flat_pack/layout_generator"

module FlatPack
  module Generators
    class LayoutGeneratorTest < Rails::Generators::TestCase
      tests LayoutGenerator
      destination File.expand_path("../../tmp/generators", __dir__)

      setup do
        test_destination = File.expand_path("../../tmp/generators/#{Process.pid}_#{name.gsub(/\W+/, "_")}", __dir__)
        self.class.destination(test_destination)
        prepare_destination
      end

      test "generates default sidebar layout files" do
        run_generator

        assert_file "app/views/layouts/flat_pack_sidebar.html.erb" do |content|
          assert_predicate content.strip, :present?
          assert_includes content, "FlatPack::SidebarLayout::Component"
          assert_includes content, 'data-theme="rounded"'
          assert_includes content, 'stylesheet_link_tag "flat_pack/variables"'
          assert_includes content, 'stylesheet_link_tag "flat_pack/application"'
          assert_includes content, 'stylesheet_link_tag "flat_pack/rich_text"'
          assert_includes content, 'render "layouts/flat_pack/sidebar"'
          assert_includes content, 'render "layouts/flat_pack/top_nav"'
        end
        assert_file "app/views/layouts/flat_pack/_sidebar.html.erb" do |content|
          assert_includes content, "FlatPack::Sidebar::Component"
          assert_includes content, "FlatPack::Sidebar::Item::Component"
        end
        assert_file "app/views/layouts/flat_pack/_top_nav.html.erb" do |content|
          assert_includes content, "FlatPack::TopNav::Component"
          assert_includes content, "toggleMobile"
        end
      end

      test "strips html erb extension from layout name" do
        run_generator %w[--layout_name admin_shell.html.erb]

        assert_file "app/views/layouts/admin_shell.html.erb"
      end

      test "accepts right sidebar side option" do
        run_generator %w[--side right --layout_name right_shell]

        assert_file "app/views/layouts/right_shell.html.erb"
      end

      test "unsupported layout type does not generate files" do
        quietly do
          run_generator %w[--type invalid]
        end

        assert_no_file "app/views/layouts/flat_pack_sidebar.html.erb"
      end

      test "unsupported side does not generate files" do
        quietly do
          run_generator %w[--side upside]
        end

        assert_no_file "app/views/layouts/flat_pack_sidebar.html.erb"
      end
    end
  end
end
