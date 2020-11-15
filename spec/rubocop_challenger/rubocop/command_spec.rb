# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::Command do
  let(:command) { described_class.new }

  before { allow(command).to receive(:execute) }

  describe '#auto_correct_all' do
    it do
      command.auto_correct_all
      expect(command)
        .to have_received(:execute)
        .with('bundle exec rubocop --auto-correct-all || true')
    end
  end

  describe '#auto_gen_config' do
    context 'without any options' do
      let(:expected) do
        'bundle exec rubocop --auto-gen-config || true'
      end

      it do
        command.auto_gen_config
        expect(command).to have_received(:execute).with(expected)
      end
    end

    context 'with exclude_limit option' do
      let(:expected) do
        'bundle exec rubocop --auto-gen-config --exclude-limit 10 || true'
      end

      it do
        command.auto_gen_config(exclude_limit: 10)
        expect(command).to have_received(:execute).with(expected)
      end
    end

    context 'with auto_gen_timestamp option' do
      let(:expected) do
        'bundle exec rubocop --auto-gen-config --no-auto-gen-timestamp || true'
      end

      it do
        command.auto_gen_config(auto_gen_timestamp: false)
        expect(command).to have_received(:execute).with(expected)
      end
    end
  end
end
