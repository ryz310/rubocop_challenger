require 'spec_helper'

RSpec.describe Challenger::Rubocop::TodoReader do
  let(:todo_reader) { described_class.new('spec/fixtures/.rubocop_todo.yml') }

  let(:autocorrectable_rule_which_offence_count_is_1) do
    Challenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 1
      # Cop supports --auto-correct.
      # Configuration parameters: EnforcedStyle.
      # SupportedStyles: empty_lines, no_empty_lines
      Layout/EmptyLinesAroundBlockBody:
        Exclude:
          - 'spec/lib/challenger/rubocop/todo_reader_spec.rb'
    CONTENTS
  end

  let(:autocorrectable_rule_which_offence_count_is_2) do
    Challenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 2
      # Cop supports --auto-correct.
      Style/ExpandPathArguments:
        Exclude:
          - 'challenger.gemspec'
    CONTENTS
  end

  let(:autocorrectable_rule_which_offence_count_is_13) do
    Challenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 13
      # Cop supports --auto-correct.
      # Configuration parameters: EnforcedStyle.
      # SupportedStyles: when_needed, always, never
      Style/FrozenStringLiteralComment:
        Exclude:
          - 'Gemfile'
          - 'Rakefile'
          - 'bin/console'
          - 'challenger.gemspec'
          - 'lib/challenger.rb'
          - 'lib/challenger/rubocop/rule.rb'
          - 'lib/challenger/rubocop/todo_editor.rb'
          - 'lib/challenger/rubocop/todo_reader.rb'
          - 'lib/challenger/version.rb'
          - 'spec/challenger/rubocop/rule_spec.rb'
          - 'spec/challenger_spec.rb'
          - 'spec/lib/challenger/rubocop/todo_reader_spec.rb'
          - 'spec/spec_helper.rb'
    CONTENTS
  end

  let(:unautocorrectable_rule_which_offence_count_is_4) do
    Challenger::Rubocop::Rule.new(<<~CONTENTS)
      # Offense count: 4
      Style/Documentation:
        Exclude:
          - 'spec/**/*'
          - 'test/**/*'
          - 'lib/challenger.rb'
          - 'lib/challenger/rubocop/rule.rb'
          - 'lib/challenger/rubocop/todo_editor.rb'
          - 'lib/challenger/rubocop/todo_reader.rb'
    CONTENTS
  end

  describe '#all_rules' do
    it 'returns all rubocop rules which ordered by offense count' do
      expect(todo_reader.all_rules).to eq(
        [
          autocorrectable_rule_which_offence_count_is_1,
          autocorrectable_rule_which_offence_count_is_2,
          unautocorrectable_rule_which_offence_count_is_4,
          autocorrectable_rule_which_offence_count_is_13,
        ]
      )
    end
  end

  describe '#auto_correctable_rules' do
    it 'returns just auto correctable rules which ordered by offense count' do
      expect(todo_reader.auto_correctable_rules).to eq(
        [
          autocorrectable_rule_which_offence_count_is_1,
          autocorrectable_rule_which_offence_count_is_2,
          autocorrectable_rule_which_offence_count_is_13,
        ]
      )
    end
  end

  describe '#least_occurrence_rule' do
    it 'returns a auto correctable rule with the least count of occurrences' do
      expect(todo_reader.least_occurrence_rule).to eq(
        autocorrectable_rule_which_offence_count_is_1
      )
    end
  end

  describe '#most_occurrence_rule' do
    it 'returns a auto correctable rule with the most count of occurrences' do
      expect(todo_reader.most_occurrence_rule).to eq(
        autocorrectable_rule_which_offence_count_is_13
      )
    end
  end

  describe '#any_rule' do
    it 'returns a auto correctable rule at random' do
      expect(todo_reader.most_occurrence_rule)
        .to eq(autocorrectable_rule_which_offence_count_is_1)
        .or eq(autocorrectable_rule_which_offence_count_is_2)
        .or eq(autocorrectable_rule_which_offence_count_is_13)
    end
  end
end
