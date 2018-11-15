# frozen_string_literal: true

module RubocopChallenger
  module Github
    # To create Pull Request
    class PrCreater
      # Returns a new instance of Github::PrCreater
      #
      # @param access_token [String] The GitHub access token
      # @param branch [String] The branch where your changes are going to
      #                        implement.
      # @param user_name [String] The username to use for committer and author
      # @param user_email [String] The email to use for committer and author
      def initialize(access_token:, branch:, user_name: nil, user_email: nil)
        @access_token = access_token
        @topic_branch = branch
        @git = Git::Command.new(user_name: user_name, user_email: user_email)
        @github = Github::Client.new(access_token, git.remote_url('origin'))
        @initial_sha1 = git.current_sha1
      end

      # Add and commit local files to this branch
      #
      # @param message [String] The commit message
      # @yield Some commands where modify local files
      # @return [Object] Return result of yield if you use &block
      # @raise [RubocopChallenger::Errors::ExistUncommittedModify]
      #        Raise error if you use &block and exists someuncommitted files
      def commit(message, &block)
        git.checkout_with(topic_branch) unless git.current_branch?(topic_branch)
        result = modify_files(&block) if block_given?
        git.add('.')
        git.commit(message)
        result
      end

      # Create a pull request
      # You should call #commit before calling this method
      #
      # @param title [String] Title for the pull request
      # @param body [String] The body for the pull request
      # @param base [String] The branch you want your changes pulled into
      # @param labels [Array<String>] An array of labels to apply to this PR
      # @return [Boolean] Return true if its successed
      def create_pr(title:, body:, base:, labels: nil)
        return false unless git_condition_valid?

        git.push(github_token_url, topic_branch)
        pr_number = github.create_pull_request(
          base: base, head: topic_branch, title: title, body: body
        )
        github.add_labels(pr_number, labels) unless labels.nil?
        true
      end

      private

      attr_reader :access_token, :git, :github, :topic_branch, :initial_sha1

      def git_condition_valid?
        !git.current_sha1?(initial_sha1) && git.current_branch?(topic_branch)
      end

      def modify_files
        raise Errors::ExistUncommittedModify if git.exist_uncommitted_modify?

        yield
      end

      def github_token_url
        "https://#{access_token}@github.com/#{github.repository}"
      end
    end
  end
end
