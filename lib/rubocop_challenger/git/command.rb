# frozen_string_literal: true

module RubocopChallenger
  module Git
    # To execute git command
    class Command < CommandLine
      def initialize(user_name: nil, user_email: nil)
        @user_name = user_name
        @user_email = user_email
      end

      def user_name
        @user_name ||= config('user.name')
      end

      def user_email
        @user_email ||= config('user.email')
      end

      def exist_uncommitted_modify?
        execute('git add -n .; git diff --name-only') != ''
      end

      def checkout(branch)
        run('checkout', branch)
      end

      def checkout_with(new_branch)
        run('checkout', '-b', new_branch)
      end

      def add(*files)
        run('add', *files)
      end

      def commit(message)
        run_with_environments('commit', '-m', "\"#{message}\"")
      end

      def push(remote, branch = current_branch)
        run('push', remote, branch)
      end

      def current_sha1
        run('rev-parse', 'HEAD')
      end

      def current_sha1?(sha1)
        current_sha1 == sha1.to_s
      end

      def current_branch
        run('rev-parse', '--abbrev-ref', 'HEAD')
      end

      def current_branch?(branch)
        current_branch == branch.to_s
      end

      def remote_url(remote)
        run('remote', 'get-url', '--push', remote)
      end

      private

      def run(*subcommands)
        command = "git #{subcommands.join(' ')}"
        execute(command)
      end

      def run_with_environments(*subcommands)
        command = "#{environments} git #{subcommands.join(' ')}"
        execute(command)
      end

      def config(key)
        run('config', key)
      end

      def environments
        @environments ||= [
          "GIT_AUTHOR_NAME=\"#{user_name}\"",
          "GIT_AUTHOR_EMAIL=\"#{user_email}\"",
          "GIT_COMMITTER_NAME=\"#{user_name}\"",
          "GIT_COMMITTER_EMAIL=\"#{user_email}\""
        ].join(' ')
      end
    end
  end
end
