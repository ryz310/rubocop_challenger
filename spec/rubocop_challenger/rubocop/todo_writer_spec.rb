# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::TodoWriter do
  let(:todo_editor) { described_class.new(source, destination) }

  describe '#delete_rule' do
    let(:source) { 'spec/fixtures/.rubocop_todo.yml' }
    let(:destination) { 'spec/fixtures/.modified_rubocop_todo.yml' }
    let(:expected) { File.read('spec/fixtures/.expected_rubocop_todo.yml') }
    let(:rule) { RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS) }
      # Offense count: 1
      # Cop supports --auto-correct.
      # Configuration parameters: EnforcedStyle.
      # SupportedStyles: empty_lines, no_empty_lines
      Layout/EmptyLinesAroundBlockBody:
        Exclude:
          - 'spec/lib/rubocop_challenger/rubocop/todo_reader_spec.rb'
    CONTENTS

    after do
      File.delete(destination)
    end

    it 'deletes target rule' do
      todo_editor.delete_rule(rule)
      expect(File.read(destination)).to eq expected
    end
  end
end
