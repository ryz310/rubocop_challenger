require 'thor'

module Challenger
  class CLI < Thor
    desc 'rubocop_challenge', 'Run `$ rubocop -a` and create PR to GitHub'
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
    option :email,
           type: :string,
           default: 'rubocop_challenge@example.com',
           aliases: :m,
           desc: 'Pull Request committer email'
    option :name,
           type: :string,
           default: 'Rubocop Challenge',
           aliases: :n,
           desc: 'Pull Request committer name'
    option :base,
           type: :string,
           default: 'master',
           desc: 'Base branch of Pull Request'
    option :labels,
           type: :array,
           default: ['rubocop challenge'],
           aliases: :l,
           desc: 'Label to give to Pull Request'
    def rubocop_challenge
      target_rule = Rubocop::Challenge.exec(options[:file_path], options[:mode])
      PRDaikou.exec(pr_daikou_options(target_rule), nil)
    end

    private

    def pr_daikou_options(target_rule)
      {
        email:  options[:mail],
        name:   options[:name],
        base:   options[:base],
        title:  target_rule.title,
        labels: options[:labels].join(','),
        topic:  "rubocop-challenge/#{target_rule.title.tr('/', '-')}",
        commit: ":robot: #{target_rule.title}"
      }.each_with_object({}) do |(k, v), memo|
        memo[k] = Shellwords.escape(v)
      end
    end
  end
end
