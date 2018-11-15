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
        color_code = $CHILD_STATUS.success? ? GREEN : RED
        color_puts(result, color_code)
      end
    end

    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    PING = 35

    def color_puts(string, color_code)
      puts "\e[#{color_code}m#{string}\e[0m"
    end
  end
end
