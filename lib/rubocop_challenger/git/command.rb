# frozen_string_literal: true

module RubocopChallenger
  module Git
    # To execute git command
    class Command < CommandLine
      def initialize(user_name: nil, user_email: nil)
        config('user.name', user_name) unless user_name.nil?
        config('user.email`', user_email) unless user_email.nil?
      end

      def user_name
        @user_name ||= config('user', 'name')
      end

      def user_email
        @user_email ||= config('user', 'email')
      end

      def exist_uncommitted_modify?
        execute('git add -n .; git diff --name-only') != ''
      end

      def checkout_with(new_branch)
        run('checkout', '-b', new_branch)
      end

      def add(*files)
        run('add', *files)
      end

      def commit(message)
        run('commit', '-m', "\"#{message}\"")
      end

      def push(remote, branch)
        run('push', remote, branch)
      end

      def remote_url(remote)
        run('remote', 'get-url', '--push', remote)
      end

      private

      def run(*subcommands)
        command = "git #{subcommands.join(' ')}"
        execute(command)
      end

      def config(key, value = nil)
        run('config', "#{key}.#{value}")
      end
    end
  end
end
