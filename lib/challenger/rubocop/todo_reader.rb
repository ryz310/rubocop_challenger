require "challenger/rubocop/rule"

module Challenger
  module Rubocop
    class TodoReader
      def initialize(rubocop_todo_file_path)
        @rubocop_todo_file_path = rubocop_todo_file_path
      end

      def auto_correctable_rules
        @auto_correctable_rules ||= extract_auto_correcable_rules
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

      def extract_auto_correcable_rules
        file = open(rubocop_todo_file_path)
        buff, char, rules = '', '', []

        loop do
          prev_char = char
          char = file.getc

          buff << char unless char.nil?
          next unless empty_line?(prev_char, char)

          rule = Rule.new(buff)
          rules << rule if rule.auto_correctable?
          buff.clear
          break if char.nil? # EOF
        end

        rules.sort!
      end

      def empty_line?(prev_char, char)
        prev_char == "\n" && (char.nil? || char == "\n")
      end
    end
  end
end
