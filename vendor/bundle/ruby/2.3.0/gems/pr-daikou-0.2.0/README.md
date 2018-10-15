# pr-daikou

[![CircleCI](https://circleci.com/gh/rvillage/pr-daikou/tree/master.svg?style=svg)](https://circleci.com/gh/rvillage/pr-daikou/tree/master)
[![Gem Version](https://badge.fury.io/rb/pr-daikou.svg)](https://badge.fury.io/rb/pr-daikou)

`pr-daikou` is agency script for Create Pull Request.

By requesting a build to CI service (e.g. CircleCI) to execute this script, Automatic code correction (e.g. `rubocop --auto-correct`, `bundle update`) is invoked, then commit changes and create pull request to GitHub repository if there some changes exist.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pr-daikou'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install pr-daikou
```

## Usage

### Setting GitHub personal access token to CircleCI

GitHub personal access token is required for sending pull requests to your repository.

1. Go to [your account's settings page](https://github.com/settings/tokens) and generate a personal access token with "repo" scope
2. On CircleCI dashboard, go to your application's "Project Settings" -> "Environment Variables"
3. Add an environment variable `GITHUB_ACCESS_TOKEN` with your GitHub personal access token

### Configure circle.yml

Configure your `.circleci/config.yml` to run `pr-daikou`, for example:

#### CircleCI1.0

```yaml
deployment:
  code_correction:
    branch: develop
    commands:
      - automatic code correction command (e.g. rubocop --auto-correct || true)
      - pr-daikou
```

#### CircleCI2.0

```yaml
version: 2

jobs:
  build:
    docker:
      - image: circleci/ruby:2.5
    steps:
      - checkout
      - run: bundle install -j4 --retry=3
      - run: automatic code correction command (e.g. rubocop --auto-correct || true)
      - run: pr-daikou
```

### CLI command references

General usage:

```ruby
$ pr-daikou --help
Usage: pr-daikou [options]
        --email EMAIL                git committed user email, default: pr_daikou@example.com
        --name NAME                  git committed user name, default: pr_daikou
    -T, --title TITLE                pull request title, default: PR daikou [at Mon Jan 1 12:34:56 UTC 2017]
        --description DESC           pull request description, default: ""
    -m, --commit MESSAGE             add git commit message, default: :robot: PR daikou
    -b, --base BRANCH                pull request base branch, default: master
    -t, --topic BRANCH               create new branch, default: ci/pr-daikou_[20170101123456.000]
    -L, --labels LABELS              add labels, which should be separated with comma, default: ""
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rvillage/pr-daikou. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the pr-daikou project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rvillage/pr-daikou/blob/master/CODE_OF_CONDUCT.md).
