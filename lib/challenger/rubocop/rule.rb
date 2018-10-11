require 'rubocop'
require 'rubocop-rspec'

module Challenger
  module Rubocop
    class Rule
      include Comparable

      attr_reader :title, :offense_count, :contents

      def initialize(contents)
        @contents = contents
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
        message_const = "RuboCop::Cop::#{title.sub('/', '::')}::MSG"
        Object.const_get(message_const) rescue '**NO DESCRIPTION**'
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
