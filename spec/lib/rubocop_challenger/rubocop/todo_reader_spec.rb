# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::TodoReader do
  let(:todo_reader) { described_class.new('spec/fixtures/.rubocop_todo.yml') }

  let(:autocorrectable_rule_which_offense_count_is_1) do
    RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 1
      # This cop supports safe auto-correction (--auto-correct).
      # Configuration parameters: EnforcedStyle.
      # SupportedStyles: empty_lines, no_empty_lines
      Layout/EmptyLinesAroundBlockBody:
        Exclude:
          - 'spec/lib/rubocop_challenger/rubocop/todo_reader_spec.rb'
    CONTENTS
  end

  let(:autocorrectable_rule_which_offense_count_is_2) do
    RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 2
      # This cop supports safe auto-correction (--auto-correct).
      Style/ExpandPathArguments:
        Exclude:
          - 'rubocop_challenger.gemspec'
    CONTENTS
  end

  let(:autocorrectable_rule_which_offense_count_is_13) do
    RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 13
      # This cop supports safe auto-correction (--auto-correct).
      # Configuration parameters: EnforcedStyle.
      # SupportedStyles: when_needed, always, never
      Style/FrozenStringLiteralComment:
        Exclude:
          - 'Gemfile'
          - 'Rakefile'
          - 'bin/console'
          - 'rubocop_challenger.gemspec'
          - 'lib/rubocop_challenger.rb'
          - 'lib/rubocop_challenger/rubocop/rule.rb'
          - 'lib/rubocop_challenger/rubocop/todo_editor.rb'
          - 'lib/rubocop_challenger/rubocop/todo_reader.rb'
          - 'lib/rubocop_challenger/version.rb'
          - 'spec/rubocop_challenger/rubocop/rule_spec.rb'
          - 'spec/rubocop_challenger_spec.rb'
          - 'spec/lib/rubocop_challenger/rubocop/todo_reader_spec.rb'
          - 'spec/spec_helper.rb'
    CONTENTS
  end

  let(:unautocorrectable_rule_which_offense_count_is_4) do
    RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 4
      Style/Documentation:
        Exclude:
          - 'spec/**/*'
          - 'test/**/*'
          - 'lib/rubocop_challenger.rb'
          - 'lib/rubocop_challenger/rubocop/rule.rb'
          - 'lib/rubocop_challenger/rubocop/todo_editor.rb'
          - 'lib/rubocop_challenger/rubocop/todo_reader.rb'
    CONTENTS
  end

  describe '#version' do
    it 'returns the version of RuboCop used to create the .rubocop_todo.yml' do
      expect(todo_reader.version).to eq '0.59.2'
    end
  end

  describe '#all_rules' do
    let(:rules_which_are_ordered_by_offense_count) do
      [
        autocorrectable_rule_which_offense_count_is_1,
        autocorrectable_rule_which_offense_count_is_2,
        unautocorrectable_rule_which_offense_count_is_4,
        autocorrectable_rule_which_offense_count_is_13
      ]
    end

    it 'returns all rubocop rules which ordered by offense count' do
      expect(todo_reader.all_rules)
        .to eq rules_which_are_ordered_by_offense_count
    end

    context 'when includes any ignored rules' do
      before do
        allow(RubocopChallenger::Rubocop::ConfigEditor)
          .to receive(:new).and_return(config_editor)
      end

      let(:config_editor) do
        instance_double(
          RubocopChallenger::Rubocop::ConfigEditor,
          ignored_rules: ignored_rules
        )
      end
      let(:ignored_rules) do
        %w[
          Layout/EmptyLinesAroundBlockBody
          Style/FrozenStringLiteralComment
        ]
      end

      it 'rejects the ignored rules' do
        expect(todo_reader.all_rules).to eq [
          autocorrectable_rule_which_offense_count_is_2,
          unautocorrectable_rule_which_offense_count_is_4
        ]
      end
    end
  end

  describe '#auto_correctable_rules' do
    let(:rules_which_are_ordered_by_offense_count) do
      [
        autocorrectable_rule_which_offense_count_is_1,
        autocorrectable_rule_which_offense_count_is_2,
        autocorrectable_rule_which_offense_count_is_13
      ]
    end

    it 'returns just auto correctable rules which ordered by offense count' do
      expect(todo_reader.auto_correctable_rules)
        .to eq rules_which_are_ordered_by_offense_count
    end
  end

  describe '#least_occurrence_rule' do
    it 'returns a auto correctable rule with the least count of occurrences' do
      expect(todo_reader.least_occurrence_rule).to eq(
        autocorrectable_rule_which_offense_count_is_1
      )
    end
  end

  describe '#most_occurrence_rule' do
    it 'returns a auto correctable rule with the most count of occurrences' do
      expect(todo_reader.most_occurrence_rule).to eq(
        autocorrectable_rule_which_offense_count_is_13
      )
    end
  end

  describe '#any_rule' do
    it 'returns a auto correctable rule at random' do
      expect(todo_reader.any_rule)
        .to eq(autocorrectable_rule_which_offense_count_is_1)
        .or eq(autocorrectable_rule_which_offense_count_is_2)
        .or eq(autocorrectable_rule_which_offense_count_is_13)
    end
  end
end
