# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Challenger::Rubocop::Rule do
  describe '#title' do
    let(:rule) { described_class.new(<<~CONTENTS) }
      # Offense count: 2
      # Configuration parameters: CountComments.
      Metrics/MethodLength:
        Max: 17
    CONTENTS

    it 'returns title of the rule' do
      expect(rule.title).to eq 'Metrics/MethodLength'
    end
  end

  describe '#offense_count' do
    let(:rule) { described_class.new(<<~CONTENTS) }
      # Offense count: 27
      # Cop supports --auto-correct.
      # Configuration parameters: EnforcedStyle, ConsistentQuotesInMultiline.
      # SupportedStyles: single_quotes, double_quotes
      Style/StringLiterals:
        Exclude:
          - 'Gemfile'
          - 'Rakefile'
          - 'bin/console'
          - 'challenger.gemspec'
          - 'lib/challenger/rubocop/todo_reader.rb'
          - 'lib/challenger/version.rb'
          - 'spec/challenger_spec.rb'
          - 'spec/spec_helper.rb'
    CONTENTS

    it 'returns offense count of the rule' do
      expect(rule.offense_count).to eq 27
    end
  end

  describe '#contents' do
    let(:rule) { described_class.new(contents) }
    let(:contents) { <<~CONTENTS }
      # Offense count: 4
      # Configuration parameters: AllowHeredoc, AllowURI, URISchemes, IgnoreCopDirectives, IgnoredPatterns.
      # URISchemes: http, https
      Metrics/LineLength:
        Max: 87
    CONTENTS

    it 'returns raw contents' do
      expect(rule.contents).to eq contents
    end
  end

  describe '#<=>' do
    subject { rule <=> other }

    let(:rule) { described_class.new(<<~CONTENTS) }
      # Offense count: 2
      # Cop supports --auto-correct.
      # Configuration parameters: EnforcedStyle, UseHashRocketsWithSymbolValues, PreferHashRocketsForNonAlnumEndingSymbols.
      # SupportedStyles: ruby19, hash_rockets, no_mixed_keys, ruby19_no_mixed_keys
      Style/HashSyntax:
        Exclude:
          - 'Rakefile'
    CONTENTS

    context 'when the rule offense count greater than other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # Cop supports --auto-correct.
        Layout/LeadingBlankLines:
          Exclude:
            - 'challenger.gemspec'
      CONTENTS

      it { is_expected.to eq(1) }
    end

    context 'when the rule offense count is equal to other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 2
        # Cop supports --auto-correct.
        Style/ExpandPathArguments:
          Exclude:
            - 'challenger.gemspec'
      CONTENTS

      it { is_expected.to be_zero }
    end

    context 'when the rule offense count is less than other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 3
        Style/Documentation:
          Exclude:
            - 'spec/**/*'
            - 'test/**/*'
            - 'lib/challenger.rb'
      CONTENTS

      it { is_expected.to eq(-1) }
    end
  end

  describe '#auto_correctable?' do
    subject { rule.auto_correctable? }

    context 'when the rule supports auto correct' do
      let(:rule) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # Cop supports --auto-correct.
        Performance/StringReplacement:
          Exclude:
            - 'lib/challenger.rb'
      CONTENTS

      it { is_expected.to be_truthy }
    end

    context 'when the rule does not support auto correct' do
      let(:rule) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        Metrics/AbcSize:
          Max: 19
      CONTENTS

      it { is_expected.to be_falsey }
    end
  end

  describe '#rubydoc_url' do
    context 'when the rule is included in the rubocop gem' do
      let(:rule) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # Cop supports --auto-correct.
        Style/RedundantSelf:
          Exclude:
            - 'lib/challenger/rubocop/rule.rb'
      CONTENTS

      it "returns rubocop gem's document url" do
        expect(rule.rubydoc_url)
          .to eq 'https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/RedundantSelf'
      end
    end

    context 'when the rule is included in the rubocop-rspec gem' do
      let(:rule) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # Cop supports --auto-correct.
        # Configuration parameters: CustomTransform, IgnoredWords.
        RSpec/ExampleWording:
          Exclude:
            - 'spec/challenger/rubocop/rule_spec.rb'
      CONTENTS

      it "returns rubocop-rspec gem's document url" do
        expect(rule.rubydoc_url)
          .to eq 'https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/ExampleWording'
      end
    end
  end
end
