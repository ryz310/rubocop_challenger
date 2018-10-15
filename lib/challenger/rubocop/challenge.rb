# frozen_string_literal: true

module Challenger
  module Rubocop
    module Challenge
      module_function

      def exec(file_path, mode)
        todo_reader = Rubocop::TodoReader.new(file_path)
        todo_writer = Rubocop::TodoWriter.new(file_path)

        target_rule =
          case mode
          when 'least_occurrence' then todo_reader.least_occurrence_rule
          when 'random'           then todo_reader.any_rule
          when 'most_occurrence'  then todo_reader.most_occurrence_rule
          else raise "`#{mode}` is not supported mode"
          end

        exit if target_rule.nil?

        todo_writer.delete_rule(target_rule)

        # Run rubocop --auto-correct
        `rubocop -a || true`

        target_rule
      end
    end
  end
end
