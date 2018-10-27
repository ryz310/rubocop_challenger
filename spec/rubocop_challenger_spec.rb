# frozen_string_literal: true

RSpec.describe RubocopChallenger do
  it 'has a version number' do
    expect(RubocopChallenger::VERSION).not_to be nil
  end

  describe 'README.md' do
    let(:readme_file) { strip_whitespace(File.read('README.md')) }

    def strip_whitespace(string)
      string.lines.map(&:strip).join("\n")
    end

    it 'includes following execution result: `$ rubocop_challenger help`' do
      execution_result = strip_whitespace(`bundle exec exe/rubocop_challenger help`)
      puts '=' * 100
      puts "readme_file : \n#{readme_file}"
      puts '=' * 100
      puts "execution_result : \n#{execution_result}"
      puts '=' * 100
      expect(readme_file).to include execution_result
    end

    it 'includes following execution result: `$ rubocop_challenger help go`' do
      execution_result = strip_whitespace(`bundle exec exe/rubocop_challenger help go`)
      expect(readme_file).to include execution_result
    end
  end
end
