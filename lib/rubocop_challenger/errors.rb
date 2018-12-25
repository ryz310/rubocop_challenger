# frozen_string_literal: true

module RubocopChallenger
  module Errors
    class ExistUncommittedModify < StandardError; end

    # Raise if no auto-correctable rule in the `.rubocop_todo.yml`.
    class NoAutoCorrectableRule < StandardError
      def initialize
        super 'There is no auto-correctable rule'
      end
    end
  end
end
