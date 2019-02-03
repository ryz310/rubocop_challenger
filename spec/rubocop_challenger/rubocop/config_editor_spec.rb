# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Rubocop::ConfigEditor do
  describe '#initialize' do
    subject(:initialized_instance) { described_class.new(file_path: file_path) }

    context 'when exists the config file' do
      let(:file_path) { 'spec/fixtures/.rubocop_challenge.yml' }

      it 'load data from the config file' do
        expect(initialized_instance.data).to eq YAML.load_file(file_path)
      end
    end

    context 'when does not exists the config file' do
      let(:file_path) { 'spec/fixtures/.not_exists.yml' }

      it 'initializes data as blank hash' do
        expect(initialized_instance.data).to eq({})
      end
    end
  end
end
