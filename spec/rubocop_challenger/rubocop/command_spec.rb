# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::Command do
  let(:command) { described_class.new }

  before { allow(command).to receive(:execute) }

  describe '#auto_correct' do
    it do
      command.auto_correct
      expect(command)
        .to have_received(:execute)
        .with('bundle exec rubocop --auto-correct || true')
    end
  end

  describe '#auto_gen_config' do
    it do
      command.auto_gen_config
      expect(command)
        .to have_received(:execute)
        .with('bundle exec rubocop --auto-gen-config || true')
    end
  end
end
