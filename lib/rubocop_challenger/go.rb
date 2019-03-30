# frozen_string_literal: true

module RubocopChallenger
  # Executes Rubocop Challenge flow
  class Go
    include CommandLine

    # @param options [Hash] describe_options_here
    def initialize(options)
      @options = options
      @pull_request = PullRequest.new(
        options[:base],
        options[:name],
        options[:email],
        options[:labels],
        options[:'no-commit']
      )
    end

    # Executes Rubocop Challenge flow
    #
    # @raise [Errors::NoAutoCorrectableRule]
    def exec
      before_version, after_version = regenerate_rubocop_todo!
      corrected_rule = rubocop_challenge!(before_version, after_version)
      regenerate_rubocop_todo!
      add_to_ignore_list_if_challenge_is_incomplete(corrected_rule)
      create_pull_request!(corrected_rule)
    end

    private

    attr_reader :options, :pull_request

    # Re-generate .rubocop_todo.yml and run git commit.
    #
    # @return [Array<String>]
    #  Returns the versions of RuboCop which created ".rubocop_todo.yml" before
    #  and after re-generate.
    def regenerate_rubocop_todo!
      before_version = load_version
      pull_request.commit! ':police_car: regenerate rubocop todo' do
        Rubocop::Command.new.auto_gen_config
      end
      after_version = load_version

      [before_version, after_version]
    end

    # @return [String]
    def load_version
      Rubocop::TodoReader.new(options[:file_path]).version
    end

    # Run rubocop challenge.
    #
    # @return [Rubocop::Rule] The corrected rule
    # @raise [Errors::NoAutoCorrectableRule]
    def rubocop_challenge!(before_version, after_version)
      Rubocop::Challenge.exec(options[:file_path], options[:mode]).tap do |rule|
        pull_request.commit! ":police_car: #{rule.title}"
      end
    rescue Errors::NoAutoCorrectableRule => e
      create_another_pull_request!(before_version, after_version)
      raise e
    end

    # Creates a pull request for the Rubocop Challenge
    #
    # @param rule [Rubocop::Rule] The corrected rule
    def create_pull_request!(corrected_rule)
      pull_request.create_rubocop_challenge_pr!(
        corrected_rule, options[:template]
      )
    end

    # Creates a pull request which re-generate ".rubocop_todo.yml" with new
    # version RuboCop. Use this method if it does not need to make a challenge
    # but ".rubocop_todo.yml" is out of date. If same both `before_version` and
    # `after_version`, it does not work.
    #
    # @param before_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml"
    #   before re-generate.
    # @param after_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml"
    #   after re-generate
    def create_another_pull_request!(before_version, after_version)
      return if before_version == after_version

      pull_request.create_regenerate_todo_pr!(before_version, after_version)
    end

    DESCRIPTION_THAT_CHALLENGE_IS_INCOMPLETE = <<~MSG
      Rubocop Challenger has executed auto-correcting but it is incomplete.
      Therefore the rule add to ignore list.
    MSG

    # If still exist the rule after a challenge, the rule regard as cannot
    # correct automatically then add to ignore list and it is not chosen as
    # target rule from next time.
    #
    # @param rule [Rubocop::Rule] The corrected rule
    def add_to_ignore_list_if_challenge_is_incomplete(rule)
      return unless auto_correct_incomplete?(rule)

      pull_request.commit! ':police_car: add the rule to the ignore list' do
        config_editor = Rubocop::ConfigEditor.new
        config_editor.add_ignore(rule)
        config_editor.save
      end
      color_puts DESCRIPTION_THAT_CHALLENGE_IS_INCOMPLETE, CommandLine::YELLOW
    end

    # Checks the challenge result. If the challenge is successed, the rule
    # should not exist in the ".rubocop_todo.yml" after regenerate.
    #
    # @param rule [Rubocop::Rule] The corrected rule
    # @return [Boolean] Return true if the challenge successed
    def auto_correct_incomplete?(rule)
      todo_reader = Rubocop::TodoReader.new(options[:file_path])
      todo_reader.all_rules.include?(rule)
    end
  end
end
