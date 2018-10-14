require 'rubocop'
require 'rubocop-rspec'
require 'challenger/rubocop/rule'
require 'challenger/rubocop/todo_reader'
require 'challenger/rubocop/todo_writer'
require 'challenger/version'
require 'pr-daikou'

module Challenger
  module_function

  def rubocop_challenge(rubocop_todo_file_path = nil, delete_target: 'most_occurrence')
    rubocop_todo_file_path ||= './.rubocop_todo.yml'
    todo_writer = Rubocop::TodoWriter.new(rubocop_todo_file_path)

    target_rule = select_target_rule(rubocop_todo_file_path, delete_target)
    todo_writer.delete_rule(target_rule)

    # Run rubocop --auto-correct
    `rubocop -a || true`

    options = {
      email: 'socialplus_admin@feedforce.jp',
      name: 'SocialPlus Bot',
      title: target_rule.title,
      labels: 'ready for review, rubocop challenge',
      topic: "rubocop-challenge/#{target_rule.title.gsub('/', '-')}",
      commit: ":robot: #{target_rule.title}"
    }

    PRDaikou.exec(options, nil)
  end

  def select_target_rule(rubocop_todo_file_path, delete_target)
    todo_reader = Rubocop::TodoReader.new(rubocop_todo_file_path)

    case delete_target
    when 'least_occurrence'
      todo_reader.least_occurrence_rule
    when 'random'
      todo_reader.any_rule
    else
      todo_reader.most_occurrence_rule
    end
  end
end
