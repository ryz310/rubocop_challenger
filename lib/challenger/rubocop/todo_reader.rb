module Challenger
  module Rubocop
    class TodoReader
      def initialize(rubocop_todo_file_path)
        @rubocop_todo_file_path = rubocop_todo_file_path
      end

      def rules
        @rules ||= extract_rules
      end

      def auto_correctable_rules
        rules.select(&:auto_correctable?)
      end

      def least_occurrence_rule
        auto_correctable_rules.first
      end

      def most_occurrence_rule
        auto_correctable_rules.last
      end

      def any_rule
        auto_correctable_rules.sample
      end

      private

      attr_reader :rubocop_todo_file_path

      def extract_rules
        file = open(rubocop_todo_file_path)
        buff, char, rules = '', '', []

        loop do
          prev_char = char
          char = file.getc

          buff << char unless char.nil?
          next unless empty_line?(prev_char, char)

          rules << Rule.new(buff)
          buff.clear
          break if char.nil? # EOF
        end

        rules.reject { |rule| rule.offense_count.zero? }.sort!
      end

      def empty_line?(prev_char, char)
        prev_char == "\n" && (char.nil? || char == "\n")
      end
    end
  end
end
