# frozen_string_literal: true

require 'thor'

module RubocopChallenger
  # To define CLI commands
  class CLI < Thor
    desc 'go', 'Run `$ rubocop --auto-correct` and create PR to GitHub repo'
    option :email,
           required: true,
           type: :string,
           desc: 'Pull Request committer email'
    option :name,
           required: true,
           type: :string,
           desc: 'Pull Request committer name'
    option :file_path,
           type: :string,
           default: '.rubocop_todo.yml',
           aliases: :f,
           desc: 'Set your ".rubocop_todo.yml" path'
    option :template,
           type: :string,
           aliases: :t,
           desc: 'Pull Request template `erb` file path.' \
                 'You can use variable that `title`, `rubydoc_url`, ' \
                 '`description` and `examples` into the erb file.'
    option :mode,
           type: :string,
           default: 'most_occurrence',
           desc: 'Mode to select deletion target. ' \
                 'You can choice "most_occurrence", "least_occurrence", ' \
                 'or "random"'
    option :base,
           type: :string,
           default: 'master',
           desc: 'Base branch of Pull Request'
    option :labels,
           type: :array,
           default: ['rubocop challenge'],
           aliases: :l,
           desc: 'Label to give to Pull Request'
    option :'regenerate-rubocop-todo',
           type: :boolean,
           default: false,
           desc: 'Rerun `$ rubocop --auto-gen-config` after autocorrect'
    option :'no-commit',
           type: :boolean,
           default: false,
           desc: 'No commit after autocorrect'
    def go
      target_rule = rubocop_challenge
      regenerate_rubocop_todo
      create_pull_request(target_rule)
    rescue StandardError => e
      puts e.message
      exit!
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

    def pr_creater
      @pr_creater ||= GitHub::PrCreater.new(
        access_token: ENV['GITHUB_ACCESS_TOKEN'],
        branch: "rubocop-challenge/#{timestamp}",
        user_name: options[:name],
        user_email: options[:email]
      )
    end

    def rubocop_challenge
      pr_creater.commit ":robot: #{target_rule.title}" do
        Rubocop::Challenge.exec(options[:file_path], options[:mode])
      end
    end

    def regenerate_rubocop_todo
      return unless options[:'regenerate-rubocop-todo']

      pr_creater.commit ':robot: regenerate rubocop todo' do
        Rubocop::Command.new.auto_gen_config
      end
    end

    def create_pull_request(rule)
      pr_creater_options = generate_pr_creater_options(rule)
      return if options[:'no-commit']

      pr_creater.create_pr(pr_creater_options)
    end

    def generate_pr_creater_options(rule)
      {
        title: "#{rule.title}-#{timestamp}",
        body: generate_pr_body(rule),
        base: options[:base],
        labels: options[:labels]
      }
    end

    def generate_pr_body(rule)
      Github::PrTemplate
        .new(rule, options[:template])
        .generate_pullrequest_markdown
    end

    def timestamp
      @timestamp ||= Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
