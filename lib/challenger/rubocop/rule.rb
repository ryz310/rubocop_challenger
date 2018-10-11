require 'rubocop'
require 'rubocop-rspec'

module Challenger
  module Rubocop
    class Rule
      include Comparable

      attr_reader :title, :offense_count, :contents

      def initialize(title, offense_count, contents)
        @title = title
        @offense_count = offense_count
        @contents = contents
      end

      def <=>(other)
        self.offense_count <=> other.offense_count
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
    end
  end
end
