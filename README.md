# Rubocop Challenger

[![CircleCI](https://circleci.com/gh/ryz310/rubocop_challenger/tree/master.svg?style=svg&circle-token=cdf0ffce5b4c0c7804b50dde00ca5ef09cbadb67)](https://circleci.com/gh/ryz310/rubocop_challenger/tree/master) [![Gem Version](https://badge.fury.io/rb/rubocop_challenger.svg)](https://badge.fury.io/rb/rubocop_challenger) [![Waffle.io - Columns and their card count](https://badge.waffle.io/ryz310/rubocop_challenger.svg?columns=all)](https://waffle.io/ryz310/rubocop_challenger)

## Usage

```yml
# Ruby CircleCI 2.0 configuration file

version: 2

jobs:
  rubocop_challenge:
    docker:
      - image: circleci/ruby:2.5-node-browsers
    working_directory: ~/repo
    steps:
      - checkout
      - run:
          name: Rubocop Challenge
          command: |
            gem install rubocop_challenger
            rubocop_challenger go \
              --email=rubocop-challenge@example.com \
              --name="'Rubocop Challenge'"

workflows:
  version: 2

  nightly:
    triggers:
      - schedule:
          cron: "30 23 * * 1,2,3" # 8:30am every Tuesday, Wednsday and Thursday (JST)
          filters:
            branches:
              only:
                - master
    jobs:
      - rubocop_challenge
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubocop_challenger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubocopChallenger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rubocop_challenger/blob/master/CODE_OF_CONDUCT.md).
