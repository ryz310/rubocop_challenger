# frozen_string_literal: true

require 'thor'

module RubocopChallenger
  # To define CLI commands
  class CLI < Thor
    include CommandLine

    desc 'go', 'Run `$ rubocop --auto-correct` and create a PR to GitHub repo'
    option :email,
           required: true,
           type: :string,
           desc: 'The Pull Request committer email'
    option :name,
           required: true,
           type: :string,
           desc: 'The Pull Request committer name'
    option :file_path,
           type: :string,
           default: '.rubocop_todo.yml',
           aliases: :f,
           desc: 'Set your ".rubocop_todo.yml" path'
    option :template,
           type: :string,
           aliases: :t,
           desc: 'A Pull Request template `erb` file path.' \
                 'You can use variable that `title`, `rubydoc_url`, ' \
                 '`description` and `examples` into the erb file.'
    option :mode,
           type: :string,
           default: 'most_occurrence',
           desc: 'Mode to select deletion target. You can choice ' \
                 '"most_occurrence", "least_occurrence", or "random"'
    option :base,
           type: :string,
           default: 'master',
           desc: 'Base branch of Pull Request'
    option :labels,
           type: :array,
           default: ['rubocop challenge'],
           aliases: :l,
           desc: 'Label to give to Pull Request'
    option :'no-commit',
           type: :boolean,
           default: false,
           desc: 'No commit after autocorrect'
    def go
      Go.new(options).exec
    rescue StandardError => e
      color_puts e.message, CommandLine::RED
      exit_process!
    end

    desc 'version', 'Show current version'
    def version
      puts RubocopChallenger::VERSION
    end

    # Workaround to return exit code 1 when an error occurs
    # @see https://github.com/erikhuda/thor/issues/244
    module ClassMethods
      def exit_on_failure?
        true
      end
    end

    private

    # Exit process (Mainly for mock when testing)
    def exit_process!
      exit!
    end
  end
end
