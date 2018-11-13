# frozen_string_literal: true

module RubocopChallenger
  module Github
    # GitHub API Client
    class Client
      attr_reader :repository

      def initialize(access_token, remote_url)
        @client = Octokit::Client.new(access_token: access_token)
        @repository = remote_url.match(REPOSITORY_MATCHER)[:repository]
      end

      # Create a pull request
      #
      # @param base [String] The branch you want your changes pulled into
      # @param head [String] The branch where your changes are implemented
      # @param title [String] Title for the pull request
      # @param body [String] The body for the pull request
      # @return [Integer] Created pull request number
      def create_pull_request(base:, head:, title:, body:)
        response =
          client.create_pull_request(repository, base, head, title, body)
        response.number
      end

      # Description of #add_labels
      #
      # @param issue_number [Integer] Number ID of the issue (or pull request)
      # @param labels [Array<String>] An array of labels to apply to this Issue
      def add_labels(issue_number, *labels)
        client.add_labels_to_an_issue(repository, issue_number, labels)
      end

      private

      REPOSITORY_MATCHER = %r{github\.com[:/](?<repository>.+)\.git}.freeze

      attr_reader :client
    end
  end
end
