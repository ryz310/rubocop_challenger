# frozen_string_literal: true

module RubocopChallenger
  # To execute command line. You should inherit this class to use.
  class CommandLine
    private

    # Execute a command
    #
    # @param command [String] The command you want to execute
    # @return [String] The result in the execution
    def execute(command)
      puts "$ #{command}"
      `#{command}`.chomp.tap do |result|
        puts result
      end
    end
  end
end
