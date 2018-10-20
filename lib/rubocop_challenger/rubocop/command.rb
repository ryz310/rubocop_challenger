# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    class Command
      def auto_correct
        `rubocop --auto-correct || true`
      end
    end
  end
end
