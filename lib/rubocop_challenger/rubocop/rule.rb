# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # Parse rubocop rule which loaded from Rubocop::TodoReader class
    class Rule
      include Comparable

      attr_reader :title, :offense_count, :contents

      def initialize(contents)
        @contents = contents.dup
        @title = extract_title
        @offense_count = extract_offense_count
      end

      def <=>(other)
        offense_count <=> other.offense_count
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

      private

      def extract_title
        contents =~ /^([^# ].+):$/
        Regexp.last_match(1)
      end

      def extract_offense_count
        contents =~ /# Offense count: (\d+)/
        Regexp.last_match(1).to_i
      end
    end
  end
end
