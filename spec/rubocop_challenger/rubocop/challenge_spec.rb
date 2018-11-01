# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::Challenge do
  describe '.exec' do
    subject(:rubocop_challenge_execute) do
      described_class.exec(file_path, mode)
    end

    let(:file_path) { './spec/fixtures/.rubocop_todo.yml' }

    let(:rule_instance) do
      instance_double(RubocopChallenger::Rubocop::Rule)
    end

    let(:command_instance) do
      instance_double(
        RubocopChallenger::Rubocop::Command,
        auto_correct: nil
      )
    end

    let(:todo_reader_instance) do
      instance_double(
        RubocopChallenger::Rubocop::TodoReader,
        least_occurrence_rule: rule_instance,
        most_occurrence_rule: rule_instance,
        any_rule: rule_instance
      )
    end

    let(:todo_writer_instance) do
      instance_double(
        RubocopChallenger::Rubocop::TodoWriter,
        delete_rule: nil
      )
    end

    before do
      allow(RubocopChallenger::Rubocop::Command)
        .to receive(:new)
        .and_return(command_instance)

      allow(RubocopChallenger::Rubocop::TodoReader)
        .to receive(:new)
        .and_return(todo_reader_instance)

      allow(RubocopChallenger::Rubocop::TodoWriter)
        .to receive(:new)
        .and_return(todo_writer_instance)
    end

    context 'when mode is least_occurrence' do
      let(:mode) { 'least_occurrence' }

      it do
        rubocop_challenge_execute
        expect(todo_reader_instance).to have_received(:least_occurrence_rule)
      end
    end

    context 'when mode is most_occurrence' do
      let(:mode) { 'most_occurrence' }

      it do
        rubocop_challenge_execute
        expect(todo_reader_instance).to have_received(:most_occurrence_rule)
      end
    end

    context 'when mode is random' do
      let(:mode) { 'random' }

      it do
        rubocop_challenge_execute
        expect(todo_reader_instance).to have_received(:any_rule)
      end
    end

    context 'when mode is not supported' do
      let(:mode) { 'xxx' }

      it do
        expect { rubocop_challenge_execute }
          .to raise_error('`xxx` is not supported mode')
      end
    end

    context 'when target rule is nil' do
      let(:mode) { 'most_occurrence' }
      let(:rule_instance) { nil }

      it do
        expect { rubocop_challenge_execute }.to raise_error(SystemExit)
      end
    end
  end
end
