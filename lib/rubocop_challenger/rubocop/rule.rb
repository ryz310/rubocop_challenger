# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    class Rule
      include Comparable

      attr_reader :title, :offense_count, :contents

      def initialize(contents)
        @contents = contents.dup
        @title = extract_title
        @offense_count = extract_offense_count
      end

      def <=>(other)
        self.offense_count <=> other.offense_count
      end

      def auto_correctable?
        contents =~ /# Cop supports --auto-correct/
      end

      def rubydoc_url
        if title.start_with?('RSpec')
          "https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/#{title}"
        else
          "https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/#{title}"
        end
      end

      def description
        YARD.parse(rubocop_class_file_path)
        yardoc = YARD::Registry.all(:class).first.format
        YARD::Registry.clear
        yardoc.strip!
      rescue StandardError
        '**NO DESCRIPTION**'
      end

      private

      def extract_title
        contents =~ /^([^# ].+):$/
        Regexp.last_match(1)
      end

      def extract_offense_count
        contents =~ /# Offense count: (\d+)/
        Regexp.last_match(1).to_i
      end

      def rubocop_class_file_path
        cop = Object.const_get("RuboCop::Cop::#{title.sub('/', '::')}").new
        source_locations =
          cop
          .methods
          .map { cop.method(m).source_location }
          .reject(&:nil?)

        source_locations.find do |source_location|
          source_location.end_with? ''
        end
      end
    end
  end
end
