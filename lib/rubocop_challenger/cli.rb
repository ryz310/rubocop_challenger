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
      regenerate_rubocop_todo
      target_rule = rubocop_challenge
      regenerate_rubocop_todo
      check_challenge_result(target_rule)
      create_pull_request(target_rule)
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

    # GitHub PR creater instance.
    def pr_creater
      @pr_creater ||= Github::PrCreater.new(
        branch: "rubocop-challenge/#{timestamp}",
        user_name: options[:name],
        user_email: options[:email]
      )
    end

    # Run rubocop challenge.
    def rubocop_challenge
      target_rule = Rubocop::Challenge.exec(options[:file_path], options[:mode])
      pr_creater.commit ":police_car: #{target_rule.title}"
      target_rule
    end

    # Re-generate .rubocop_todo.yml and run git commit.
    def regenerate_rubocop_todo
      pr_creater.commit ':police_car: regenerate rubocop todo' do
        Rubocop::Command.new.auto_gen_config
      end
    end

    # Check the challenge result. When the challenge successed, the rule dose
    # not exist in the .rubocop_todo.yml after regenerate it too.
    # If still exist the rule, the rule regard as cannot correct automatically
    # then add to ignore list and it is not chosen as target rule from next
    # time.
    #
    # @param rule [Rubocop::Rule] The target rule
    def check_challenge_result(rule)
      todo_reader = Rubocop::TodoReader.new(options[:file_path])
      return unless todo_reader.all_rules.include?(rule)

      config_editor = Rubocop::ConfigEditor.new
      config_editor.add_ignore(rule)
      config_editor.save
    end

    # Create a PR with description of what modification were made.
    #
    # @param rule [Rubocop::Rule] The target rule
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

    # Exit process (Mainly for mock when testing)
    def exit_process!
      exit!
    end
  end
end
