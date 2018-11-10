# frozen_string_literal: true

module RubocopChallenger
  module Github
    # To create Pull Request
    class PrCreater
      def initialize(access_token, user_name: nil, user_email: nil)
        @git = Git::Command.new(user_name: user_name, user_email: user_email)
        @github = Github::Client.new(access_token, git.remote_url)
      end

      def exec(title:, body:, base:, topic:, message:, labels: [])
        return unless git.exist_uncommitted_modify?

        git.checkout_with(topic)
        git.add('.')
        git.commit(message)
        git.push('origin', topic)

        pr_number = github.create_pull_request(
          base: base, head: topic, title: title, body: body
        )
        github.add_labels(pr_number, labels)
      end

      private

      attr_reader :git, :github
    end
  end
end
