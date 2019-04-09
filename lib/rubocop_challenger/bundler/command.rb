# frozen_string_literal: true

module RubocopChallenger
  module Bundler
    # To execute bundler command
    class Command
      include PrComet::CommandLine

      def update(*gem_names)
        run('update', *gem_names)
      end

      def installed?(gem_name)
        !run('list', '|', 'grep', gem_name).empty?
      end

      private

      def run(*subcommands)
        command = "bundle #{subcommands.join(' ')}"
        execute(command)
      end
    end
  end
end
