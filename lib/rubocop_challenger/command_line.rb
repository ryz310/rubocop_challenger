# frozen_string_literal: true

module RubocopChallenger
  # To execute command line. You should inherit this class to use.
  class CommandLine
    private

    def execute(command)
      puts "BEGIN: #{command}"
      result = `#{command}`
      puts "END: #{command}"
      result.chomp
    end
  end
end
