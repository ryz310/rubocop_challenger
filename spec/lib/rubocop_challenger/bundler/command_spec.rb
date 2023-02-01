# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Bundler::Command do
  let(:command) { described_class.new }

  before { allow(command).to receive(:execute) }

  describe '#update' do
    before do
      allow(command).to receive(:installed?) do |gem_name|
        gem_name != 'not-installed-gem'
      end
    end

    context 'with no arguments' do
      it do
        command.update
        expect(command).not_to have_received(:execute)
      end
    end

    context 'with a single gem name' do
      it do
        command.update('rubocop')
        expect(command).to have_received(:execute).with('bundle update rubocop --conservative')
      end
    end

    context 'with multiple gem names' do
      it 'updates the gems only installed' do
        command.update('rubocop', 'rubocop-rspec', 'not-installed-gem')
        expect(command)
          .to have_received(:execute)
          .with('bundle update rubocop rubocop-rspec --conservative')
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
