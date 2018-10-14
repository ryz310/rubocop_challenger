require 'thor'

module Challenger
  class CLI < Thor
    desc 'rubocop_challenge', 'Run `$ rubocop -a` and create PR to GitHub'
    option :file_path, type: :string, default: '.rubocop_todo.yml'
    option :mode, type: :string, default: 'most_occurrence'
    option :commiter_email, type: :string, default: 'rubocop_challenge@example.com'
    option :commiter_name, type: :string, default: 'Rubocop Challenge'
    option :base_branch, type: :string, default: 'master'
    option :pull_request_labels, type: :array, default: ['rubocop challenge']
    def rubocop_challenge
      target_rule = Rubocop::Challenge.exec(file_path, mode)
      PRDaikou.exec(
        {
          email:  commiter_email,
          name:   commiter_name,
          title:  target_rule.title,
          labels: pull_request_labels,
          topic:  "rubocop-challenge/#{target_rule.title.tr('/', '-')}",
          commit: ":robot: #{target_rule.title}"
        }, nil
      )
    end
  end
end
