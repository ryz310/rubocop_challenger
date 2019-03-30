# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Bundler::Command do
  let(:command) { described_class.new }

  before { allow(command).to receive(:execute) }

  describe '#update' do
    context 'when no argument is given' do
      it do
        command.update
        expect(command).to have_received(:execute).with('bundle update')
      end
    end

    context 'when only one gem name is given' do
      it do
        command.update('rubocop')
        expect(command).to have_received(:execute).with('bundle update rubocop')
      end
    end

    context 'when multiple gem names are given' do
      let(:gem_names) { 'rubocop' }

      it do
        command.update('rubocop', 'rubocop-rspec')
        expect(command)
          .to have_received(:execute)
          .with('bundle update rubocop rubocop-rspec')
      end
    end
  end

  describe '#installed?' do
    subject { command.installed?(gem_name) }

    before { allow(command).to receive(:execute).and_call_original }

    context 'when the gem is installed' do
      let(:gem_name) { 'rspec' }

      it { is_expected.to be_truthy }
    end

    context 'when the gem is not installed' do
      let(:gem_name) { 'rails' }

      it { is_expected.to be_falsey }
    end
  end
end
