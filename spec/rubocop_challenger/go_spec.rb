# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Go do
  let(:go) { described_class.new(options) }

  let(:options) do
    {
      email: 'rubocop-challenger@example.com',
      name: 'Rubocop Challenger',
      file_path: '.rubocop_todo.yml',
      mode: 'most_occurrence',
      base: 'master',
      labels: ['rubocop challenge'],
      'no-commit': false
    }
  end

  let(:corrected_rule) do
    instance_double(
      RubocopChallenger::Rubocop::Rule, title: 'Style/StringLiterals'
    )
  end
  let(:rubocop_command) do
    instance_double(RubocopChallenger::Rubocop::Command, auto_gen_config: nil)
  end
  let(:pr_tempate) do
    instance_double(
      RubocopChallenger::Github::PrTemplate,
      generate_pullrequest_markdown: 'The pull request markdown'
    )
  end
  let(:todo_reader) do
    instance_double(RubocopChallenger::Rubocop::TodoReader, all_rules: [])
  end
  let(:config_editor) do
    instance_double(
      RubocopChallenger::Rubocop::ConfigEditor, add_ignore: nil, save: nil
    )
  end
  let(:pr_creater) { RubocopChallenger::Github::PrCreater::Mock.new }

  before do
    allow(RubocopChallenger::Rubocop::Challenge)
      .to receive(:exec).and_return(corrected_rule)
    allow(RubocopChallenger::Rubocop::Command)
      .to receive(:new).and_return(rubocop_command)
    allow(RubocopChallenger::Github::PrTemplate)
      .to receive(:new).and_return(pr_tempate)
    allow(RubocopChallenger::Rubocop::ConfigEditor)
      .to receive(:new).and_return(config_editor)
    allow(RubocopChallenger::Rubocop::TodoReader)
      .to receive(:new).and_return(todo_reader)
    allow(RubocopChallenger::Github::PrCreater)
      .to receive(:new).and_return(pr_creater)

    allow(pr_creater).to receive(:create_pr)
    allow(go).to receive(:timestamp).and_return('20181112212509')
    allow(go).to receive(:color_puts)
  end

  describe '#exec' do
    subject(:exec) { go.exec }

    let(:expected_params) do
      {
        title: 'Style/StringLiterals-20181112212509',
        body: 'The pull request markdown',
        base: 'master',
        labels: ['rubocop challenge']
      }
    end

    shared_examples 'standard flow of the Rubocop Challenge' do
      it do
        exec
        expect(rubocop_command)
          .to have_received(:auto_gen_config).with(no_args).twice
      end

      it do
        exec
        expect(RubocopChallenger::Rubocop::Challenge)
          .to have_received(:exec)
          .with('.rubocop_todo.yml', 'most_occurrence')
      end

      it do
        exec
        expect(pr_creater).to have_received(:create_pr).with(expected_params)
      end
    end

    context 'when succeeded to auto-correcting' do
      it_behaves_like 'standard flow of the Rubocop Challenge'

      it do
        exec
        expect(config_editor).not_to have_received(:add_ignore)
      end
    end

    context 'when failed to auto-correcting' do
      before do
        allow(todo_reader).to receive(:all_rules).and_return([corrected_rule])
      end

      it_behaves_like 'standard flow of the Rubocop Challenge'

      it do
        exec
        expect(config_editor).to have_received(:add_ignore).with(corrected_rule)
      end

      it do
        exec
        expect(go).to have_received(:color_puts).with(instance_of(String), 33)
      end
    end
  end
end
