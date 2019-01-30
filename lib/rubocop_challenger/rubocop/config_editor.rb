# frozen_string_literal: true

require 'yaml'

module RubocopChallenger
  module Rubocop
    # To edit rubocop_challenger config file
    class ConfigEditor
      FILE_PATH = '.rubocop_challenge.yml'
      attr_reader :data

      def initialize
        @data = FileTest.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH) : {}
      end

      # Get ignored rules
      #
      # @return [Array<String>] Ignored rules
      def ignored_rules
        data[:ignore] || []
      end

      def add_ignore(rule)
        data[:ignore] ||= []
        data[:ignore] << rule.title
        data[:ignore].sort!
      end

      def save
        YAML.dump(data, File.open(FILE_PATH, 'w'))
      end
    end
  end
end
