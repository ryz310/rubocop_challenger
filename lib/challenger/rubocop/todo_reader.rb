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
          break if char.nil? # EOF

          buff << char
          next unless empty_line?(prev_char, char)

          if auto_correctable?(buff)
            title = extract_title(buff)
            offense_count = extract_offense_count(buff)
            contents = buff.dup

            rules << Rule.new(title, offense_count, contents)
          end
          buff = ''
        end

        rules.sort!
      end

      def empty_line?(prev_char, char)
        prev_char == "\n" && char == "\n"
      end

      def extract_title(rule)
        rule =~ /^([^# ].+):$/
        Regexp.last_match(1)
      end

      def extract_offense_count(rule)
        auto_correctable?(rule)
        Regexp.last_match(1).to_i
      end

      def auto_correctable?(rule)
        rule =~ /# Offense count: (\d+)\n# Cop supports --auto-correct\./
      end
    end
  end
end
