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
        File
          .read(rubocop_todo_file_path)
          .split(/\n{2,}/)
          .map! { |content| Rule.new(content) }
          .reject! { |rule| rule.offense_count.zero? }
          .sort!
      end
    end
  end
end
