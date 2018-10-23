# frozen_string_literal: true

require 'erb'
require 'rubocop'
require 'rubocop-rspec'
require 'rubocop_challenger/rubocop/rule'
require 'rubocop_challenger/rubocop/todo_reader'
require 'rubocop_challenger/rubocop/todo_writer'
require 'rubocop_challenger/rubocop/command'
require 'rubocop_challenger/rubocop/challenge'
require 'rubocop_challenger/cli'
require 'rubocop_challenger/version'
require 'rubocop_challenger/github/pr_template.rb'
require 'pr-daikou'

module RubocopChallenger
end
