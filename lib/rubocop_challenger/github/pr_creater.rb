# frozen_string_literal: true

module RubocopChallenger
  module Github
    # To create Pull Request
    class PrCreater
      def initialize(access_token, branch:, user_name: nil, user_email: nil)
        @topic_branch = branch
        @git = Git::Command.new(user_name: user_name, user_email: user_email)
        @github = Github::Client.new(access_token, git.remote_url)
        @initial_sha1 = git.current_sha1
      end

      def commit(message)
        git.checkout_with(topic_branch) unless git.current_branch?(topic_branch)
        git.add('.')
        git.commit(message)
      end

      # Create a pull request
      # You should call #commit before calling this method
      #
      # @param title [String] Title for the pull request
      # @param body [String] The body for the pull request
      # @param base [String] The branch you want your changes pulled into
      # @param labels [Array<String>] An array of labels to apply to this PR
      # @return [Boolean] Return true if its successed
      def create_pr(title:, body:, base:, labels: [])
        return false if git.current_sha1?(initial_sha1)
        return false unless git.current_branch?(topic_branch)

        git.push('origin', topic_branch)
        pr_number = github.create_pull_request(
          base: base, head: topic_branch, title: title, body: body
        )
        github.add_labels(pr_number, labels)
        true
      end

      private

      attr_reader :git, :github, :topic_branch, :initial_sha1
    end
  end
end
