# frozen_string_literal: true

require 'yaml'

module RubocopChallenger
  module Rubocop
    # To edit rubocop_challenger config file
    class ConfigEditor
      DEFAULT_FILE_PATH = '.rubocop_challenge.yml'

      attr_reader :data, :file_path

      def initialize(file_path: DEFAULT_FILE_PATH)
        @file_path = file_path
        @data = FileTest.exist?(file_path) ? YAML.load_file(file_path) : {}
      end

      # Get ignored rules
      #
      # @return [Array<String>] Ignored rules
      def ignored_rules
        data[:Ignore] || []
      end

      # Add ignore rule to the config data
      def add_ignore(rule)
        data[:Ignore] ||= []
        data[:Ignore] << rule.title
        data[:Ignore].uniq!.sort!
      end

      # Save setting to the config file as YAML
      def save
        YAML.dump(data, File.open(file_path, 'w'))
      end
    end
  end
end
