require 'optparse'

module PRDaikou
  # Command Line Interface
  class CLI
    class << self
      def parse_options
        new.parse
      end
    end

    def initialize
      @options = {
        commit:      ':robot: PR daikou',
        title:       'PR daikou',
        description: '',
        email:       'pr_daikou@example.com',
        name:        'pr_daikou',
        base:        'master',
        topic:       'ci/pr-daikou',
        labels:      ''
      }
    end

    def parse(argv: ARGV)
      args = parser.parse(argv)
      [@options, args]
    end

    private

    def parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = 'Usage: pr-daikou [options]'

        opt.on('--email EMAIL', "git committed user email, default: #{@options[:email]}") {|v| @options[:email] = v }
        opt.on('--name NAME', "git committed user name, default: #{@options[:name]}") {|v| @options[:name] = v }
        opt.on('-T', '--title TITLE', "pull request title, default: #{@options[:title]} [at Mon Jan 1 12:34:56 UTC 2017]") {|v| @options[:title] = v }
        opt.on('--description DESC', "pull request description, default: #{@options[:description]}") {|v| @options[:description] = v }
        opt.on('-m', '--commit MESSAGE', "add git commit message, default: #{@options[:commit]}") {|v| @options[:commit] = v }
        opt.on('-b', '--base BRANCH', "pull request base branch, default: #{@options[:base]}") {|v| @options[:base] = v }
        opt.on('-t', '--topic BRANCH', "create new branch, default: #{@options[:topic]}_[20170101123456.000]") {|v| @options[:topic] = v }
        opt.on('-L', '--labels LABELS', "add labels, which should be separated by comma, default: #{@options[:labels]}") {|v| @options[:labels] = v }
      end
    end
  end
end
