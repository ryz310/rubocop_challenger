# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Github::PrCreater do
  let(:pr_creater) do
    described_class.new(
      access_token: 'GITHUB_ACCESS_TOKEN',
      branch: 'topic_branch'
    )
  end

  let(:git_command) do
    instance_double(
      RubocopChallenger::Git::Command,
      add: '',
      commit: '',
      push: '',
      remote_url: 'git@github.com:ryz310/rubocop_challenger.git',
      current_sha1: '1234567890',
      'current_sha1?': false,
      'current_branch?': true,
      'exist_uncommitted_modify?': false
    )
  end

  let(:github_client) do
    instance_double(
      RubocopChallenger::Github::Client,
      create_pull_request: 1234,
      add_labels: ''
    )
  end

  before do
    allow(RubocopChallenger::Git::Command)
      .to receive(:new).and_return(git_command)

    allow(RubocopChallenger::Github::Client)
      .to receive(:new).and_return(github_client)
  end

  describe '#commit' do
    context 'with &block' do
      subject(:commit) do
        pr_creater.commit('commit message') { 123 }
      end

      it 'returns result of yield' do
        expect(commit).to eq 123
      end

      it do
        commit
        expect(git_command).to have_received(:commit).with('commit message')
      end
    end

    context 'without &block' do
      subject(:commit) do
        pr_creater.commit 'commit message'
      end

      it { is_expected.to be_nil }

      it do
        commit
        expect(git_command).to have_received(:commit).with('commit message')
      end
    end
  end

  describe '#create_pr' do
    subject(:create_pr) do
      pr_creater.create_pr(
        title: 'The pull request title',
        body: 'The pull request body',
        base: 'master',
        labels: labels
      )
    end

    let(:labels) { nil }

    shared_examples 'to call create pull request API' do
      let(:expected_parameters) do
        {
          base: 'master',
          head: 'topic_branch',
          title: 'The pull request title',
          body: 'The pull request body'
        }
      end

      it { is_expected.to be_truthy }

      it do
        create_pr
        expect(github_client)
          .to have_received(:create_pull_request)
          .with(expected_parameters)
      end
    end

    shared_examples 'not to call create pull request API' do
      let(:expected_parameters) do
        {
          base: 'master',
          head: 'topic_branch',
          title: 'The pull request title',
          body: 'The pull request body'
        }
      end

      it { is_expected.to be_falsey }

      it do
        create_pr
        expect(github_client).not_to have_received(:create_pull_request)
      end
    end

    context 'with labels option' do
      let(:labels) { ['label a', 'label b'] }

      it_behaves_like 'to call create pull request API' do
        it do
          create_pr
          expect(github_client)
            .to have_received(:add_labels)
            .with(1234, ['label a', 'label b'])
        end
      end
    end

    context 'without labels option' do
      it_behaves_like 'to call create pull request API' do
        it do
          create_pr
          expect(github_client).not_to have_received(:add_labels)
        end
      end
    end

    context 'when no commit' do
      before do
        allow(git_command)
          .to receive(:current_sha1?).with('1234567890').and_return(true)
      end

      it_behaves_like 'not to call create pull request API'
    end

    context 'when no checkout' do
      before do
        allow(git_command)
          .to receive(:current_branch?).with('topic_branch').and_return(false)
      end

      it_behaves_like 'not to call create pull request API'
    end
  end
end
