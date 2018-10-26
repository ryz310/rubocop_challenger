# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::Yardoc do
  let(:yardoc) { described_class.new(title) }
  let(:title) { 'Layout/SpaceInsidePercentLiteralDelimiters' }

  describe '#description' do
    let(:docstring) { <<~DOCSTRING.chomp }
      Checks for unnecessary additional spaces inside the delimiters of
      %i/%w/%x literals.
    DOCSTRING

    it 'returns cop description using yardoc' do
      expect(yardoc.description).to eq docstring
    end
  end

  describe '#examples' do
    let(:example) { <<~EXAMPLE.chomp }

      # good
      %i(foo bar baz)

      # bad
      %w( foo bar baz )

      # bad
      %x(  ls -l )
    EXAMPLE

    it 'returns cop examples using yardoc' do
      expect(yardoc.examples).to eq [example]
    end
  end
end
