# Rubocop Challenger

[![CircleCI](https://circleci.com/gh/ryz310/rubocop_challenger/tree/master.svg?style=svg&circle-token=cdf0ffce5b4c0c7804b50dde00ca5ef09cbadb67)](https://circleci.com/gh/ryz310/rubocop_challenger/tree/master) [![Gem Version](https://badge.fury.io/rb/rubocop_challenger.svg)](https://badge.fury.io/rb/rubocop_challenger) [![Waffle.io - Columns and their card count](https://badge.waffle.io/ryz310/rubocop_challenger.svg?columns=all)](https://waffle.io/ryz310/rubocop_challenger)

If you introduce [`rubocop`](https://github.com/rubocop-hq/rubocop) to an existing Rails project later, you will use [`$ rubocop --auto-gen-config`](https://github.com/rubocop-hq/rubocop/blob/master/manual/configuration.md#automatically-generated-configuration). But it will make a huge `.rubocop_todo.yml` and make you despair.
On the other hand, `rubocop` has [`--auto-correct`](https://github.com/rubocop-hq/rubocop/blob/master/manual/basic_usage.md#other-useful-command-line-flags) option, it is possible to automatically repair the writing which does not conform to the rule. But since it occasionally destroys your code, it is quite dangerous to apply all at once.
It is ideal that to remove a disabled rule from `.rubocop_todo.yml` every day, to check whether it passes test, and can be obtained consent from the team. But it requires strong persistence and time.
I call such work *Rubocop Challenge*. And the *RubocopChallenger* is a gem to support this challenge!

## Rubocop Challenge Flow

1. Run *RubocopChallenger* periodically from CI tool etc.
1. When *RubocopChallenger* starts, delete a disabled rule from `.rubocop_todo.yml` existing in your project, execute `$ rubocop --auto-correct` and create a PR which include modified results
1. You confirm the PR passes testing and then merge it if there is no problem

## Usage

### 1. Setting GitHub personal access token

GitHub personal access token is required for sending pull requests to your repository.

1. Go to [your account's settings page](https://github.com/settings/tokens) and [generate a new token](https://github.com/settings/tokens/new) with "repo" scope
  ![generate token](images/generate_token.png)
1. On [CircleCI](https://circleci.com) dashboard, go to your application's "Project Settings" -> "Environment Variables"
1. Add an environment variable `GITHUB_ACCESS_TOKEN` with your GitHub personal access token
  ![circleci environment variables](images/circleci_environment_variables.png)

### 2. Configure .circleci/config.yml

Configure your `.circleci/config.yml` to run rubocop_challenger, for example:

```yml
# .circleci/config.yml
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
            gem install -N rubocop_challenger
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

## CLI command references

```sh
$ rubocop_challenger help

Commands:
  rubocop_challenger go --email=EMAIL --name=NAME  # Run `$ rubocop --auto-correct` and create PR to your GitHub repository
  rubocop_challenger help [COMMAND]                # Describe available commands or one specific command
  rubocop_challenger version                       # Show current version
```

### Command-line Flags

```sh
$ rubocop_challenger help go

Usage:
  rubocop_challenger go --email=EMAIL --name=NAME

Options:
      --email=EMAIL                                                # Pull Request committer email
      --name=NAME                                                  # Pull Request committer name
  f, [--file-path=FILE_PATH]                                       # Set your ".rubocop_todo.yml" path
                                                                   # Default: .rubocop_todo.yml
  t, [--template=TEMPLATE]                                         # Pull Request template `erb` file path.You can use variable that `title`, `rubydoc_url` and `description` into the erb file.
      [--mode=MODE]                                                # Mode to select deletion target. You can choice "most_occurrence", "least_occurrence", or "random"
                                                                   # Default: most_occurrence
      [--base=BASE]                                                # Base branch of Pull Request
                                                                   # Default: master
  l, [--labels=one two three]                                      # Label to give to Pull Request
                                                                   # Default: ["rubocop challenge"]
      [--regenerate-rubocop-todo], [--no-regenerate-rubocop-todo]  # Rerun `$ rubocop --auto-gen-config` after autocorrect
      [--no-commit]                                                # No commit after autocorrect

Run `$ rubocop --auto-correct` and create PR to your GitHub repository
```

## Requirement

* Ruby 2.3 or higher
    * NOTE: Ruby 2.3 will EOL soon (See: [Ruby Maintenance Branches](https://www.ruby-lang.org/en/downloads/branches/))

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryz310/rubocop_challenger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubocopChallenger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ryz310/rubocop_challenger/blob/master/CODE_OF_CONDUCT.md).
