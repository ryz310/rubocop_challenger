module Challenger
  module Rubocop
    class TodoWriter
      def initialize(rubocop_todo_file_path)
        @rubocop_todo_file_path = rubocop_todo_file_path
      end

      def delete_rule(rubocop_rule)
        current_data = File.read(rubocop_todo_file_path)
        File.write(rubocop_todo_file_path, current_data.sub(rubocop_rule.contents, ''))
      end

      private

      attr_reader :rubocop_todo_file_path
    end
  end
end
