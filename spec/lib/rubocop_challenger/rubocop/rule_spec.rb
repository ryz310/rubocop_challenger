# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::Rule do
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
      # This cop supports safe autocorrection (--autocorrect).
      # Configuration parameters: EnforcedStyle, ConsistentQuotesInMultiline.
      # SupportedStyles: single_quotes, double_quotes
      Style/StringLiterals:
        Exclude:
          - 'Gemfile'
          - 'Rakefile'
          - 'bin/console'
          - 'rubocop_challenger.gemspec'
          - 'lib/rubocop_challenger/rubocop/todo_reader.rb'
          - 'lib/rubocop_challenger/version.rb'
          - 'spec/rubocop_challenger_spec.rb'
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

  describe '#==' do
    subject { rule == other }

    let(:rule) { described_class.new(<<~CONTENTS) }
      # Offense count: 2
      # This cop supports safe autocorrection (--autocorrect).
      # Configuration parameters: EnforcedStyle, UseHashRocketsWithSymbolValues, PreferHashRocketsForNonAlnumEndingSymbols.
      # SupportedStyles: ruby19, hash_rockets, no_mixed_keys, ruby19_no_mixed_keys
      Style/HashSyntax:
        Exclude:
          - 'Rakefile'
    CONTENTS

    context 'when the rule title is same to other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # This cop supports safe autocorrection (--autocorrect).
        Style/HashSyntax:
          Exclude:
            - 'rubocop_challenger.gemspec'
      CONTENTS

      it { is_expected.to be_truthy }
    end

    context 'when the rule title is different to other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # This cop supports safe autocorrection (--autocorrect).
        Layout/LeadingBlankLines:
          Exclude:
            - 'rubocop_challenger.gemspec'
      CONTENTS

      it { is_expected.to be_falsey }
    end
  end

  describe '#<=>' do
    subject { rule <=> other }

    let(:rule) { described_class.new(<<~CONTENTS) }
      # Offense count: 2
      # This cop supports safe autocorrection (--autocorrect).
      # Configuration parameters: EnforcedStyle, UseHashRocketsWithSymbolValues, PreferHashRocketsForNonAlnumEndingSymbols.
      # SupportedStyles: ruby19, hash_rockets, no_mixed_keys, ruby19_no_mixed_keys
      Style/HashSyntax:
        Exclude:
          - 'Rakefile'
    CONTENTS

    context 'when the rule offense count greater than other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # This cop supports safe autocorrection (--autocorrect).
        Layout/LeadingBlankLines:
          Exclude:
            - 'rubocop_challenger.gemspec'
      CONTENTS

      it { is_expected.to eq(1) }
    end

    context 'when the rule offense count is equal to other one' do
      let(:other) { described_class.new(<<~CONTENTS) }
        # Offense count: 2
        # This cop supports safe autocorrection (--autocorrect).
        Style/ExpandPathArguments:
          Exclude:
            - 'rubocop_challenger.gemspec'
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
            - 'lib/rubocop_challenger.rb'
      CONTENTS

      it { is_expected.to eq(-1) }
    end
  end

  describe '#autocorrectable?' do
    subject { rule.autocorrectable? }

    describe 'rubocop v1.25.0' do
      context 'with auto-correction comment: Cop supports --auto-correct' do
        let(:rule) { described_class.new(<<~CONTENTS) }
          # Offense count: 1
          # Cop supports --auto-correct.
          Performance/StringReplacement:
            Exclude:
              - 'lib/rubocop_challenger.rb'
        CONTENTS

        it { is_expected.to be_truthy }
      end
    end

    describe 'rubocop v1.26.0' do
      context 'with auto-correction comment: This cop supports safe auto-correction' do
        let(:rule) { described_class.new(<<~CONTENTS) }
          # Offense count: 1
          # This cop supports safe auto-correction (--auto-correct).
          Performance/StringReplacement:
            Exclude:
              - 'lib/rubocop_challenger.rb'
        CONTENTS

        it { is_expected.to be_truthy }
      end

      context 'with auto-correction comment: This cop supports unsafe auto-correction' do
        let(:rule) { described_class.new(<<~CONTENTS) }
          # Offense count: 1
          # This cop supports unsafe auto-correction (--auto-correct-all).
          Performance/StringReplacement:
            Exclude:
              - 'lib/rubocop_challenger.rb'
        CONTENTS

        it { is_expected.to be_truthy }
      end
    end

    describe 'rubocop v1.30.0' do
      context 'with autocorrection comment: This cop supports safe autocorrection' do
        let(:rule) { described_class.new(<<~CONTENTS) }
          # Offense count: 1
          # This cop supports safe autocorrection (--autocorrect).
          Performance/StringReplacement:
            Exclude:
              - 'lib/rubocop_challenger.rb'
        CONTENTS

        it { is_expected.to be_truthy }
      end

      context 'with autocorrection comment: This cop supports unsafe autocorrection' do
        let(:rule) { described_class.new(<<~CONTENTS) }
          # Offense count: 1
          # This cop supports unsafe autocorrection (--autocorrect-all).
          Performance/StringReplacement:
            Exclude:
              - 'lib/rubocop_challenger.rb'
        CONTENTS

        it { is_expected.to be_truthy }
      end
    end

    context 'without autocorrection comment' do
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
        # This cop supports safe autocorrection (--autocorrect).
        Style/RedundantSelf:
          Exclude:
            - 'lib/rubocop_challenger/rubocop/rule.rb'
      CONTENTS

      it "returns rubocop gem's document url" do
        expect(rule.rubydoc_url)
          .to eq 'https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/RedundantSelf'
      end
    end

    context 'when the rule is included in the rubocop-rspec gem' do
      let(:rule) { described_class.new(<<~CONTENTS) }
        # Offense count: 1
        # This cop supports safe autocorrection (--autocorrect).
        # Configuration parameters: CustomTransform, IgnoredWords.
        RSpec/ExampleWording:
          Exclude:
            - 'spec/rubocop_challenger/rubocop/rule_spec.rb'
      CONTENTS

      it "returns rubocop-rspec gem's document url" do
        expect(rule.rubydoc_url)
          .to eq 'https://www.rubydoc.info/gems/rubocop-rspec/RuboCop/Cop/RSpec/ExampleWording'
      end
    end
  end
end
