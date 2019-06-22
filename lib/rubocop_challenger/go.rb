# frozen_string_literal: true

module RubocopChallenger
  # Executes Rubocop Challenge flow
  class Go
    # @param options [Hash]
    #   Options for the rubocop challenge
    # @option exclude-limit [Integer]
    #   For how many exclude properties when creating the ".rubocop_todo.yml"
    # @option auto-gen-timestamp [Boolean]
    #   Include the date and time when creating the ".rubocop_todo.yml"
    # @option name [String]
    #   The author name which use at the git commit
    # @option email [String]
    #   The email address which use at the git commit
    # @option labels [Array<String>]
    #   Will create a pull request with the labels
    # @option no-create-pr [Boolean]
    #   Does not create a pull request when given `true`
    # @option project_column_name [String]
    #   A project column name. You can add the created PR to the GitHub project
    # @option project_id [Integer]
    #   A target project ID. If does not supplied, this method will find a
    #   project which associated the repository. When the repository has
    #   multiple projects, you should supply this.
    def initialize(options)
      @options = options
      @exclude_limit = options[:'exclude-limit']
      @auto_gen_timestamp = options[:'auto-gen-timestamp']
      @pull_request = PullRequest.new(extract_pull_request_options(options))
    end

    # Executes Rubocop Challenge flow
    #
    # @raise [Errors::NoAutoCorrectableRule]
    #   Raises if there is no auto correctable rule in ".rubocop_todo.yml"
    def exec
      update_rubocop!
      before_version, after_version = regenerate_rubocop_todo!
      corrected_rule = rubocop_challenge!(before_version, after_version)
      regenerate_rubocop_todo!
      add_to_ignore_list_if_challenge_is_incomplete(corrected_rule)
      create_pull_request!(corrected_rule)
    end

    private

    attr_reader :options, :pull_request, :exclude_limit, :auto_gen_timestamp

    # Extracts options for the PullRequest class
    #
    # @param options [Hash] The target options
    # @return [Hash] Options for the PullRequest class
    def extract_pull_request_options(options)
      {
        user_name: options[:name],
        user_email: options[:email],
        base_branch: options[:base_branch],
        labels: options[:labels],
        dry_run: options[:'no-create-pr'],
        project_column_name: options[:project_column_name],
        project_id: options[:project_id]
      }
    end

    # Executes `$ bundle update` for the rubocop and the associated gems
    def update_rubocop!
      bundler = Bundler::Command.new
      pull_request.commit! ':police_car: $ bundle update rubocop' do
        bundler.update 'rubocop',
                       'rubocop-performance',
                       'rubocop-rails',
                       'rubocop-rspec'
      end
    end

    # Re-generate .rubocop_todo.yml and run git commit.
    #
    # @return [Array<String>]
    #  Returns the versions of RuboCop which created ".rubocop_todo.yml" before
    #  and after re-generate.
    def regenerate_rubocop_todo!
      before_version = scan_rubocop_version_in_rubocop_todo_file
      pull_request.commit! ':police_car: regenerate rubocop todo' do
        Rubocop::Command.new.auto_gen_config(
          exclude_limit: exclude_limit,
          auto_gen_timestamp: auto_gen_timestamp
        )
      end
      after_version = scan_rubocop_version_in_rubocop_todo_file

      [before_version, after_version]
    end

    # @return [String] The version of RuboCop which created ".rubocop_todo.yml"
    def scan_rubocop_version_in_rubocop_todo_file
      Rubocop::TodoReader.new(options[:file_path]).version
    end

    # Run rubocop challenge.
    #
    # @param before_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" before
    #   re-generate.
    # @param after_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" after
    #   re-generate
    # @return [Rubocop::Rule]
    #   The corrected rule
    # @raise [Errors::NoAutoCorrectableRule]
    #   Raises if there is no auto correctable rule in ".rubocop_todo.yml"
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
    # @param corrected_rule [Rubocop::Rule] The corrected rule
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
    #   The version of RuboCop which created ".rubocop_todo.yml" before
    #   re-generate.
    # @param after_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" after
    #   re-generate
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
      puts Rainbow(DESCRIPTION_THAT_CHALLENGE_IS_INCOMPLETE).yellow
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
