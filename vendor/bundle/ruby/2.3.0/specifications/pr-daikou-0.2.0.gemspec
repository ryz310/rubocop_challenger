# -*- encoding: utf-8 -*-
# stub: pr-daikou 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pr-daikou".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["rvillage".freeze]
  s.date = "2018-10-01"
  s.description = "Create GitHub PullRequest of code changes in CI Service".freeze
  s.email = ["rvillage@gmail.com".freeze]
  s.executables = ["pr-daikou".freeze]
  s.files = ["bin/pr-daikou".freeze]
  s.homepage = "https://github.com/rvillage/pr-daikou".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "2.7.7".freeze
  s.summary = "Create GitHub PullRequest of code changes in CI Service".freeze

  s.installed_by_version = "2.7.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.16"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
  end
end
