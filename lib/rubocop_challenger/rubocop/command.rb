# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    class Command
      def auto_correct
        `bundle exec rubocop --auto-correct || true`
      end

      def auto_gen_config
        `bundle exec rubocop --auto-gen-config || true`
      end
    end
  end
end
