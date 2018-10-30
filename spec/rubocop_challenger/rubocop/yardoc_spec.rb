# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::Yardoc do
  let(:yardoc) { described_class.new(title) }
  let(:title) { 'Style/Alias' }

  describe '#description' do
    let(:docstring) { <<~DOCSTRING.chomp }
      This cop enforces the use of either `#alias` or `#alias_method`
      depending on configuration.
      It also flags uses of `alias :symbol` rather than `alias bareword`.
    DOCSTRING

    it 'returns cop description using yardoc' do
      expect(yardoc.description).to eq docstring
    end
  end

  describe '#examples' do
    let(:example_1) { <<~EXAMPLE.chomp }
      # bad
      alias_method :bar, :foo
      alias :bar :foo

      # good
      alias bar foo
    EXAMPLE

    let(:example_2) { <<~EXAMPLE.chomp }
      # bad
      alias :bar :foo
      alias bar foo

      # good
      alias_method :bar, :foo
    EXAMPLE

    it 'returns Array which includes cop examples name and text using yardoc' do
      expect(yardoc.examples).to eq [
        ['EnforcedStyle: prefer_alias (default)', example_1],
        ['EnforcedStyle: prefer_alias_method',    example_2]
      ]
    end
  end
end
