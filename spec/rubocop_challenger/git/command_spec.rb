# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Git::Command do
  let(:command) { described_class.new(params) }
  let(:params) do
    { user_name: nil, user_email: nil }
  end

  before { allow(command).to receive(:execute) }

  describe '#user_name' do
    it do
      command.user_name
      expect(command).to have_received(:execute).with('git config user.name')
    end
  end

  describe '#user_email' do
    it do
      command.user_email
      expect(command).to have_received(:execute).with('git config user.email')
    end
  end

  describe '#exist_uncommitted_modify?' do
    subject(:execute) { command.exist_uncommitted_modify? }

    it do
      execute
      expect(command)
        .to have_received(:execute)
        .with('git add -n .; git diff --name-only')
    end

    context 'when exist uncommitted modify' do
      before { allow(command).to receive(:execute).and_return('foo.rb') }

      it { is_expected.to be_truthy }
    end

    context 'when does not exist uncommitted modify' do
      before { allow(command).to receive(:execute).and_return('') }

      it { is_expected.to be_falsey }
    end
  end

  describe '#checkout_with' do
    it do
      command.checkout_with('{new branch}')
      expect(command)
        .to have_received(:execute)
        .with('git checkout -b {new branch}')
    end
  end

  describe '#add' do
    it do
      command.add('.')
      expect(command).to have_received(:execute).with('git add .')
    end

    it do
      command.add('foo.rb', 'bar.rb')
      expect(command).to have_received(:execute).with('git add foo.rb bar.rb')
    end
  end

  describe '#commit' do
    it do
      command.commit('message')
      expect(command).to have_received(:execute).with('git commit -m "message"')
    end
  end

  describe '#push' do
    it do
      command.push('origin', 'new_branch')
      expect(command)
        .to have_received(:execute)
        .with('git push origin new_branch')
    end
  end

  describe '#current_branch' do
    it do
      command.current_branch
      expect(command)
        .to have_received(:execute)
        .with('git rev-parse --abbrev-ref HEAD')
    end
  end

  describe '#current_branch?' do
    subject { command.current_branch?('branch_name') }

    context 'when current branch name and argument ones are same' do
      before do
        allow(command).to receive(:current_branch).and_return('branch_name')
      end

      it { is_expected.to be_truthy }
    end

    context 'when current branch name and argument ones are different' do
      before do
        allow(command).to receive(:current_branch).and_return('another_branch')
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#remote_url' do
    it do
      command.remote_url('origin')
      expect(command)
        .to have_received(:execute)
        .with('git remote get-url --push origin')
    end
  end
end
