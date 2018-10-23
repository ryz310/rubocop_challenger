# frozen_string_literal: true

require 'thor'

module RubocopChallenger
  class CLI < Thor
    desc 'go', 'Run `$ rubocop --auto-correct` and create PR to your GitHub repository'
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
    option :mode,
           type: :string,
           default: 'most_occurrence',
           desc: 'Mode to select deletion target. ' \
                 'You can choice "most_occurrence", "least_occurrence", or "random"'
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
      target_rule = Rubocop::Challenge.exec(options[:file_path], options[:mode])
      pr_daikou_options = generate_pr_daikou_options(target_rule)
      PRDaikou.exec(pr_daikou_options, nil) unless options[:'no-commit']
    rescue StandardError => e
      puts e.message
      exit!
    end

    desc 'version', 'Show current version'
    def version
      puts RubocopChallenger::VERSION
    end

    module ClassMethods
      # Workaround to return exit code 1 when an error occurs
      # @see https://github.com/erikhuda/thor/issues/244
      def exit_on_failure?
        true
      end
    end

    private

    def generate_pr_daikou_options(target_rule)
      {
        email:  options[:email],
        name:   options[:name],
        base:   options[:base],
        title:  target_rule.title,
        description: pr_template(target_rule),
        labels: options[:labels].join(','),
        topic:  generate_topic(target_rule),
        commit: ":robot: #{target_rule.title}"
      }
    end

    def generate_topic(rule)
      "rubocop-challenge/#{rule.title.tr('/', '-')}-#{timestamp}"
    end

    def pr_template(rule)
      Github::PrTemplate.new(rule).generate_pullrequest_markdown
    end

    def timestamp
      Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
