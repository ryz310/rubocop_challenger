# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::CLI do
  let(:cli) { described_class.new }
  let(:options) do
    {
      email: 'rubocop-challenger@example.com',
      name: 'Rubocop Challenger',
      file_path: '.rubocop_todo.yml',
      mode: 'most_occurrence',
      base: 'master',
      labels: ['rubocop challenge'],
      'regenerate-rubocop-todo': false,
      'no-commit': false
    }
  end
  let(:rubocop_command) do
    instance_double(RubocopChallenger::Rubocop::Command, auto_gen_config: nil)
  end
  let(:target_rule) do
    instance_double(
      RubocopChallenger::Rubocop::Rule, title: 'Style/StringLiterals'
    )
  end
  let(:pr_tempate) do
    instance_double(
      RubocopChallenger::Github::PrTemplate,
      generate_pullrequest_markdown: 'The pull request markdown'
    )
  end
  let(:pr_creater) do
    instance_double(
      RubocopChallenger::Github::PrCreater, commit: nil, create_pr: nil
    )
  end

  before do
    allow(cli).to receive(:options).and_return(options)
    allow(cli).to receive(:timestamp).and_return('20181112212509')
    allow(cli).to receive(:color_puts)
    allow(cli).to receive(:exit_process!)

    allow(RubocopChallenger::Rubocop::Challenge)
      .to receive(:exec).and_return(target_rule)
    allow(RubocopChallenger::Rubocop::Command)
      .to receive(:new).and_return(rubocop_command)
    allow(RubocopChallenger::Github::PrCreater)
      .to receive(:new).and_return(pr_creater)
    allow(RubocopChallenger::Github::PrTemplate)
      .to receive(:new).and_return(pr_tempate)
  end

  describe '#go' do
    subject(:go) { cli.go }

    let(:expected_params) do
      {
        title: 'Style/StringLiterals-20181112212509',
        body: 'The pull request markdown',
        base: 'master',
        labels: ['rubocop challenge']
      }
    end

    context 'without a exception' do
      it 'executes Rubocop Challenge and creates a Pull Request' do
        go
        expect(RubocopChallenger::Rubocop::Challenge)
          .to have_received(:exec).ordered
        expect(pr_creater)
          .to have_received(:create_pr).with(expected_params).ordered
      end
    end

    context 'with a exception' do
      before do
        allow(cli).to receive(:rubocop_challenge).and_raise('Error message')
      end

      it 'outputs a error message and exit process' do
        go
        expect(cli)
          .to have_received(:color_puts).with('Error message', 31).ordered
        expect(cli)
          .to have_received(:exit_process!).ordered
      end
    end

    context 'when raise Errors::NoAutoCorrectableRule' do
      before do
        allow(RubocopChallenger::Rubocop::Challenge)
          .to receive(:exec)
          .and_raise(RubocopChallenger::Errors::NoAutoCorrectableRule)
      end

      it 'outputs a description and exit process' do
        go
        expect(RubocopChallenger::Rubocop::Challenge)
          .to have_received(:exec).ordered
        expect(cli)
          .to have_received(:color_puts)
          .with('There is no auto-correctable rule', 33).ordered
        expect(cli)
          .to have_received(:exit_process!).at_least(:once)
      end
    end
  end

  describe '#version' do
    it do
      expect { cli.version }
        .to output("#{RubocopChallenger::VERSION}\n").to_stdout
    end
  end
end
