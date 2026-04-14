# frozen_string_literal: true

require "json"

module FlatPack
  class InstallContract
    PATH = FlatPack::Engine.root.join("docs/ai/install_contract.json")

    class << self
      def path
        PATH
      end

      def data
        @data ||= JSON.parse(File.read(path))
      end

      def pretty_json
        JSON.pretty_generate(data)
      end

      def reset!
        @data = nil
      end
    end
  end
end
