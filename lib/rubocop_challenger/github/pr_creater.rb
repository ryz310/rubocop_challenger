# frozen_string_literal: true

module RubocopChallenger
  module Github
    # To create Pull Request
    class PrCreater
      def initialize(access_token, branch:, user_name: nil, user_email: nil)
        @topic_branch = branch
        @git = Git::Command.new(user_name: user_name, user_email: user_email)
        @github = Github::Client.new(access_token, git.remote_url)
      end

      def commit(message)
        git.checkout_with(topic_branch) unless git.current_branch?(topic_branch)
        git.add('.')
        git.commit(message)
      end

      def exec(title:, body:, base:, labels: [])
        return unless git.current_branch?(topic_branch)

        git.push('origin', topic_branch)

        pr_number = github.create_pull_request(
          base: base, head: topic_branch, title: title, body: body
        )
        github.add_labels(pr_number, labels)
      end

      private

      attr_reader :git, :github, :topic_branch
    end
  end
end
