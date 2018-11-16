# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::CommandLine do
  let(:command_line) do
    class MockClass
      include RubocopChallenger::CommandLine
    end
    MockClass.new
  end

  describe '#execute' do
    subject(:execute) { command_line.send(:execute, command) }

    context 'when the execution was succeeded' do
      let(:command) { 'echo Hello world' }

      it 'returns a executed command standard output' do
        expect(execute).to eq 'Hello world'
      end

      it 'outputs the command execution to stdout with color code GREEN' do
        expect { execute }.to output(<<~STDOUT).to_stdout
          $ echo Hello world
          \e[32mHello world\e[0m
        STDOUT
      end
    end

    context 'when the execution was failed' do
      let(:command) { 'echo Hello world && false' }

      it 'returns a executed command standard output' do
        expect(execute).to eq 'Hello world'
      end

      it 'outputs the command execution to stdout with color code RED' do
        expect { execute }.to output(<<~STDOUT).to_stdout
          $ echo Hello world && false
          \e[31mHello world\e[0m
        STDOUT
      end
    end
  end
end
