# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::CommandLine do
  let(:command_line) { described_class.new }

  describe '#execute' do
    subject(:execute) { command_line.send(:execute, command) }

    let(:command) { 'echo Hello world' }

    it 'returns executed command standard output' do
      expect(execute).to eq 'Hello world'
    end

    it 'outputs command execution to stdout' do
      expect { execute }.to output("$ echo Hello world\n").to_stdout
    end
  end
end
