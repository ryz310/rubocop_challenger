# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To execute rubocop gem command (Mainly for mock when testing)
    class Command < CommandLine
      def auto_correct
        execute('bundle exec rubocop --auto-correct || true')
      end

      def auto_gen_config
        execute('bundle exec rubocop --auto-gen-config || true')
      end
    end
  end
end
