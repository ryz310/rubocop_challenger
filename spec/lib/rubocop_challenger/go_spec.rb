# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Go do
  let(:go) do
    described_class.new(
      email: 'rubocop-challenger@example.com',
      name: 'Rubocop Challenger',
      file_path: '.rubocop_todo.yml',
      mode: 'most_occurrence',
      base_branch: 'master',
      labels: ['rubocop challenge'],
      template: 'template_file_path',
      project_column_name: 'Column 1',
      project_id: 123_456_789,
      'no-create-pr': false,
      'auto-gen-timestamp': false,
      'only-safe-auto-correct': false,
      'exclude-limit': 99,
      verbose: false
    )
  end

  let(:pull_request) do
    instance_double(
      RubocopChallenger::PullRequest,
      create_rubocop_challenge_pr!: nil,
      create_regenerate_todo_pr!: nil
    )
  end
  let(:corrected_rule) do
    instance_double(
      RubocopChallenger::Rubocop::Rule, title: 'Style/StringLiterals'
    )
  end
  let(:bundler_command) do
    instance_double(
      RubocopChallenger::Bundler::Command, update: nil, installed?: true
    )
  end
  let(:rubocop_command) do
    instance_double(RubocopChallenger::Rubocop::Command, auto_gen_config: nil)
  end
  let(:todo_reader) do
    instance_double(
      RubocopChallenger::Rubocop::TodoReader, all_rules: [], version: '0.65.0'
    )
  end
  let(:config_editor) do
    instance_double(
      RubocopChallenger::Rubocop::ConfigEditor, add_ignore: nil, save: nil
    )
  end

  before do
    allow(RubocopChallenger::PullRequest)
      .to receive(:new).and_return(pull_request)
    allow(RubocopChallenger::Bundler::Command)
      .to receive(:new).and_return(bundler_command)
    allow(RubocopChallenger::Rubocop::Challenge)
      .to receive(:exec).and_return(corrected_rule)
    allow(RubocopChallenger::Rubocop::Command)
      .to receive(:new).and_return(rubocop_command)
    allow(RubocopChallenger::Rubocop::ConfigEditor)
      .to receive(:new).and_return(config_editor)
    allow(RubocopChallenger::Rubocop::TodoReader)
      .to receive(:new).and_return(todo_reader)

    allow(go).to receive(:color_puts)
    allow(pull_request).to receive(:commit!) { |&block| block&.call }
  end

  describe '#exec' do
    subject(:exec) { go.exec }

    let(:safe_exec) do
      lambda do
        exec
      rescue StandardError
        nil
      end
    end

    shared_examples 'build PullRequest instance with the options' do
      let(:expected_options) do
        {
          user_name: 'Rubocop Challenger',
          user_email: 'rubocop-challenger@example.com',
          base_branch: 'master',
          labels: ['rubocop challenge'],
          dry_run: false,
          project_column_name: 'Column 1',
          project_id: 123_456_789,
          verbose: false
        }
      end

      it do
        safe_exec.call
        expect(RubocopChallenger::PullRequest)
          .to have_received(:new).with(expected_options)
      end
    end

    shared_examples 'execute Rubocop Challenge flow' do
      let(:expected_options) do
        {
          file_path: '.rubocop_todo.yml',
          mode: 'most_occurrence',
          only_safe_auto_correct: false
        }
      end

      it do
        exec
        expect(RubocopChallenger::Bundler::Command)
          .to have_received(:new).with(verbose: false)
      end

      it do
        exec
        expect(bundler_command).to have_received(:update).with(
          'rubocop', 'rubocop-performance', 'rubocop-rails', 'rubocop-rake', 'rubocop-rspec', 'rubocop-thread_safety'
        )
      end

      it do
        exec
        expect(rubocop_command)
          .to have_received(:auto_gen_config)
          .with(exclude_limit: 99, auto_gen_timestamp: false).twice
      end

      it do
        exec
        expect(RubocopChallenger::Rubocop::Challenge)
          .to have_received(:exec)
          .with(expected_options)
      end

      it do
        exec
        expect(pull_request)
          .to have_received(:create_rubocop_challenge_pr!)
          .with(corrected_rule, 'template_file_path')
      end
    end

    context 'when the normal case' do
      it_behaves_like 'build PullRequest instance with the options'
      it_behaves_like 'execute Rubocop Challenge flow'

      it do
        exec
        expect(config_editor).not_to have_received(:add_ignore)
      end
    end

    context 'when auto-correcting is incomplete' do
      before do
        allow(todo_reader).to receive(:all_rules).and_return([corrected_rule])
      end

      it_behaves_like 'build PullRequest instance with the options'
      it_behaves_like 'execute Rubocop Challenge flow'

      it do
        exec
        expect(config_editor).to have_received(:add_ignore).with(corrected_rule)
      end
    end

    context 'when there is no auto correctable rule in ".rubocop_todo.yml"' do
      before do
        allow(RubocopChallenger::Rubocop::Challenge)
          .to receive(:exec)
          .and_raise(RubocopChallenger::Errors::NoAutoCorrectableRule)
      end

      shared_examples 'interrupt the Rubocop Challenge' do
        let(:expected_options) do
          {
            file_path: '.rubocop_todo.yml',
            mode: 'most_occurrence',
            only_safe_auto_correct: false
          }
        end

        it do
          safe_exec.call
          expect(bundler_command).to have_received(:update).with(
            'rubocop', 'rubocop-performance', 'rubocop-rails', 'rubocop-rake', 'rubocop-rspec', 'rubocop-thread_safety'
          )
        end

        it do
          safe_exec.call
          expect(rubocop_command)
            .to have_received(:auto_gen_config)
            .with(exclude_limit: 99, auto_gen_timestamp: false).once
        end

        it do
          safe_exec.call
          expect(RubocopChallenger::Rubocop::Challenge)
            .to have_received(:exec)
            .with(expected_options)
        end

        it do
          expect { exec }
            .to raise_error(RubocopChallenger::Errors::NoAutoCorrectableRule)
        end

        it do
          safe_exec.call
          expect(config_editor).not_to have_received(:add_ignore)
        end
      end

      context 'when updates ".rubocop_todo.yml"' do
        before do
          allow(todo_reader).to receive(:version).and_return('0.64.0', '0.65.0')
        end

        it_behaves_like 'build PullRequest instance with the options'
        it_behaves_like 'interrupt the Rubocop Challenge'

        it do
          safe_exec.call
          expect(pull_request)
            .to have_received(:create_regenerate_todo_pr!)
            .with('0.64.0', '0.65.0')
        end
      end

      context 'when does not update ".rubocop_todo.yml"' do
        it_behaves_like 'build PullRequest instance with the options'
        it_behaves_like 'interrupt the Rubocop Challenge'

        it do
          safe_exec.call
          expect(pull_request)
            .not_to have_received(:create_regenerate_todo_pr!)
        end
      end
    end
  end
end
