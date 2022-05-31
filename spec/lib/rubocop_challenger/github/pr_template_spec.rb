# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubocopChallenger::Github::PrTemplate do
  describe '#generate' do
    let(:pr_template) { described_class.new(rule) }

    let(:rule) { RubocopChallenger::Rubocop::Rule.new(<<~CONTENTS) }
      # Offense count: 2
      # This cop supports safe autocorrection (--autocorrect).
      Style/Alias:
        Enabled: false
    CONTENTS

    context 'when normal case' do
      let(:expected_template) { <<~EXPECTED }
        # Rubocop challenge!

        [Style/Alias](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Alias)

        **Safe autocorrect: Yes**
        :white_check_mark: The autocorrect a cop does is safe (equivalent) by design.

        ## Description

        > ### Overview
        >
        > Enforces the use of either `#alias` or `#alias_method`
        > depending on configuration.
        > It also flags uses of `alias :symbol` rather than `alias bareword`.
        >
        > ### Examples
        >
        > #### EnforcedStyle: prefer_alias (default)
        >
        > ```rb
        > # bad
        > alias_method :bar, :foo
        > alias :bar :foo
        >
        > # good
        > alias bar foo
        > ```
        >
        > #### EnforcedStyle: prefer_alias_method
        >
        > ```rb
        > # bad
        > alias :bar :foo
        > alias bar foo
        >
        > # good
        > alias_method :bar, :foo
        > ```

        Auto generated by [rubocop_challenger](https://github.com/ryz310/rubocop_challenger)
      EXPECTED

      it 'returns PR template which includes rubydoc link and description' do
        expect(pr_template.generate).to eq expected_template
      end
    end

    context 'when any error raised' do
      before do
        allow(RubocopChallenger::Rubocop::Yardoc)
          .to receive(:new).and_raise(error)
      end

      let(:error) do
        Class.new(StandardError) do
          def initialize
            super('uninitialized constant RuboCop::Cop::Style::Alias')
          end

          def backtrace
            [
              'lib/rubocop_challenger/github/pr_template.rb:3:in `yardoc`',
              'lib/rubocop_challenger/github/pr_template.rb:2:in `description`',
              'lib/rubocop_challenger/github/pr_template.rb:1:in `generate`'
            ]
          end
        end
      end

      let(:expected_template) { <<~EXPECTED }
        # Rubocop challenge!

        [Style/Alias](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Alias)

        ## Description

        Failed to create the cop description.
        Please report bugs [here](https://github.com/ryz310/rubocop_challenger/issues/new?assignees=ryz310&labels=bug&template=bug_report.md) with following error information.

        ```
        title: Style/Alias
        message: uninitialized constant RuboCop::Cop::Style::Alias

        ---
        lib/rubocop_challenger/github/pr_template.rb:3:in `yardoc`
        lib/rubocop_challenger/github/pr_template.rb:2:in `description`
        lib/rubocop_challenger/github/pr_template.rb:1:in `generate`
        ```

        Auto generated by [rubocop_challenger](https://github.com/ryz310/rubocop_challenger)
      EXPECTED

      it 'returns PR template which includes error information' do
        expect(pr_template.generate).to eq expected_template
      end
    end
  end
end
