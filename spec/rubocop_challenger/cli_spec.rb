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
      'no-commit': false
    }
  end

  before do
    allow(cli).to receive(:options).and_return(options)
    allow(cli).to receive(:color_puts)
    allow(cli).to receive(:exit_process!)
  end

  describe '#go' do
    subject(:go) { cli.go }

    context 'without a exception' do
      let(:go_instance) { instance_double(RubocopChallenger::Go, exec: nil) }

      before do
        allow(RubocopChallenger::Go).to receive(:new).and_return(go_instance)
      end

      it 'calls RubocopChallenger::Go#exec' do
        go
        expect(RubocopChallenger::Go).to have_received(:new).with(options)
        expect(go_instance).to have_received(:exec)
      end
    end

    context 'with a exception' do
      before do
        allow(RubocopChallenger::Go).to receive(:new).and_raise('Error message')
      end

      it 'outputs a error message and exit process' do
        go
        expect(cli)
          .to have_received(:color_puts)
          .with('Error message', 31).ordered
        expect(cli).to have_received(:exit_process!).ordered
      end
    end

    context 'when raise Errors::NoAutoCorrectableRule' do
      before do
        allow(RubocopChallenger::Go)
          .to receive(:new)
          .and_raise(RubocopChallenger::Errors::NoAutoCorrectableRule)
      end

      it 'outputs a description and exit process' do
        go
        expect(cli)
          .to have_received(:color_puts)
          .with('There is no auto-correctable rule', 33)
      end

      it 'does not return exit code 1' do
        go
        expect(cli).not_to have_received(:exit_process!)
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
