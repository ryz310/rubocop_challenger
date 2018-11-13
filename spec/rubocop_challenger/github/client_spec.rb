# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Github::Client do
  let(:client) { described_class.new('GITHUB_ACCESS_TOKEN', remote_url) }
  let(:remote_url) { 'https://github.com/ryz310/rubocop_challenger.git' }
  let(:octokit_mock) do
    instance_double(
      Octokit::Client,
      create_pull_request: sawyer_response,
      add_labels_to_an_issue: nil
    )
  end
  let(:sawyer_response) { OpenStruct.new(number: 123) }

  before { allow(Octokit::Client).to receive(:new).and_return(octokit_mock) }

  describe '#repository' do
    context 'when use https protocol to the git remote URL' do
      let(:remote_url) { 'https://github.com/ryz310/rubocop_challenger.git' }

      it 'returns the github repository name' do
        expect(client.repository).to eq 'ryz310/rubocop_challenger'
      end
    end

    context 'when use git protocol to the git remote URL' do
      let(:remote_url) { 'git@github.com:ryz310/rubocop_challenger.git' }

      it 'returns the github repository name' do
        expect(client.repository).to eq 'ryz310/rubocop_challenger'
      end
    end
  end

  describe '#create_pull_request' do
    subject(:create_pull_request) do
      client.create_pull_request(
        base: 'base', head: 'head', title: 'title', body: 'body'
      )
    end

    it 'calls Octokit::Client#create_pull_request' do
      create_pull_request
      expect(octokit_mock)
        .to have_received(:create_pull_request)
        .with('ryz310/rubocop_challenger', 'base', 'head', 'title', 'body')
    end

    it 'returns created pull request number' do
      expect(create_pull_request).to eq 123
    end
  end

  describe '#add_labels' do
    subject(:add_labels) { client.add_labels(1234, 'label a', 'label b') }

    it 'calls Octokit::Client#add_labels_to_an_issue' do
      add_labels
      expect(octokit_mock)
        .to have_received(:add_labels_to_an_issue)
        .with('ryz310/rubocop_challenger', 1234, ['label a', 'label b'])
    end
  end
end
