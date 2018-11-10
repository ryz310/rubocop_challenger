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
    it do
      command.user_email
      expect(command).to have_received(:execute).with('git config user.email')
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
end
