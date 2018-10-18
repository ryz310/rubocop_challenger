# frozen_string_literal: true

require 'thor'

module RubocopChallenger
  class CLI < Thor
    desc 'go', 'Run `$ rubocop -a` and create PR to GitHub'
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
    def go
      target_rule = Rubocop::Challenge.exec(options[:file_path], options[:mode])
      PRDaikou.exec(pr_daikou_options(target_rule), nil)
    end

    private

    def pr_daikou_options(target_rule)
      {
        email:  options[:email],
        name:   options[:name],
        base:   options[:base],
        title:  target_rule.title,
        labels: options[:labels].join(','),
        topic:  topic(target_rule),
        commit: ":robot: #{target_rule.title}"
      }
    end

    def topic(rule)
      "rubocop-challenge/#{rule.title.tr('/', '-')}-#{timestamp}"
    end

    def timestamp
      Time.now.strftime('%Y%m%d%H%M%S')
    end
  end
end
