# frozen_string_literal: true

module RubocopChallenger
  # Executes Rubocop Challenge flow
  class Go
    # @param options [Hash] describe_options_here
    def initialize(options)
      @options = options
    end

    # @raise [Errors::NoAutoCorrectableRule]
    def exec
      regenerate_rubocop_todo!
      corrected_rule = rubocop_challenge!
      regenerate_rubocop_todo!
      if auto_correct_incomplete?(corrected_rule)
        add_ignore_list!(corrected_rule)
      end
      create_pull_request!(corrected_rule)
    end

    private

    attr_reader :options

    # Re-generate .rubocop_todo.yml and run git commit.
    def regenerate_rubocop_todo!
      pr_creater.commit ':police_car: regenerate rubocop todo' do
        Rubocop::Command.new.auto_gen_config
      end
    end

    # Run rubocop challenge.
    #
    # @return [Rubocop::Rule] The corrected rule
    def rubocop_challenge!
      corrected_rule =
        Rubocop::Challenge.exec(options[:file_path], options[:mode])
      pr_creater.commit ":police_car: #{corrected_rule.title}"
      corrected_rule
    end

    # GitHub PR creater instance.
    def pr_creater
      @pr_creater ||= Github::PrCreater.new(
        branch: "rubocop-challenge/#{timestamp}",
        user_name: options[:name],
        user_email: options[:email]
      )
    end

    # Check the challenge result. When the challenge successed, the rule dose
    # not exist in the .rubocop_todo.yml after regenerate it too.
    #
    # @param rule [Rubocop::Rule] The target rule
    # @return [Boolean] Return true if the challenge successed
    def auto_correct_incomplete?(rule)
      todo_reader = Rubocop::TodoReader.new(options[:file_path])
      todo_reader.all_rules.include?(rule)
    end

    # If still exist the rule, the rule regard as cannot correct automatically
    # then add to ignore list and it is not chosen as target rule from next
    # time.
    #
    # @param rule [Rubocop::Rule] The target rule
    def add_ignore_list!(rule)
      pr_creater.commit ':police_car: add the rule to the ignore list' do
        config_editor = Rubocop::ConfigEditor.new
        config_editor.add_ignore(rule)
        config_editor.save
      end
    end

    # Create a PR with description of what modification were made.
    #
    # @param rule [Rubocop::Rule] The target rule
    def create_pull_request!(rule)
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
