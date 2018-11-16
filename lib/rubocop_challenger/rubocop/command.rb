# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To execute rubocop gem command (Mainly for mock when testing)
    class Command
      include CommandLine

      def auto_correct
        run('--auto-correct')
      end

      def auto_gen_config
        run('--auto-gen-config')
      end

      private

      def run(*subcommands)
        command = "bundle exec rubocop #{subcommands.join(' ')} || true"
        execute(command)
      end
    end
  end
end
