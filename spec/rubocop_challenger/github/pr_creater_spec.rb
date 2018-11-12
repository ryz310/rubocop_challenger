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
end
