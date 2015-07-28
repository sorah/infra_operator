# InfraOperator

(important note: still in early development phase)

InfraOperator provides unified interface to do something on servers, with various platform. It provides the following:

- __commands:__ A oneline shell script or some equivalent (e.g. PowerShell, Ruby script)
- __backends:__ Execute commands and return results. Execution method may vary (via SSH, via exec(3), etc...). But provides same interface for all.
- __platforms:__ Collection of providers for the target host platform.
- __providers:__ Generate suitable _command_ for target to do something.
- __inventory:__ Collects host's informations and metrics. It may use command generator (described above) to collect informations.

Also, InfraOperator provides compatible API for [SpecInfra](https://github.com/serverspec/specinfra). My goal is to replace SpecInfra with InfraOperator implementation.

## Usage

``` ruby
require 'infra_operator'

# locally
host = InfraOperator::Host.new

# or
host = InfraOperator::Host.new(
  backend: InfraOperator::Backends::Ssh.new(
    host: 'example.org',
    user: 'ops',
  ),
)

# you can manually specify target platform
host = InfraOperator::Host.new(
  platform: InfraOperator::Platforms::Ubuntu::Systemd,
)

# customize all.
host = InfraOperator::Host.new(
  backend: InfraOperator::Backends::Ssh.new(
    host: 'example.org',
    user: 'ops',
  ),
  platform: InfraOperator::Platforms::Osx.new(
    services: {package: :homebrew},
  ),
)

###

p host.backend
p host.platform
p host.services

###

p host.run(:service, :status, 'nginx')
p host.run(:file, :check_is_owned_by_user, '/tmp', 'ops')
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'infra_operator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install infra_operator

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Terminologies

- detector:
- command: represents command or something like shell script. may transform into single String, or may be executed directly.
- action: 
- command generator:
  - environment: where target host runs (e.g. virtualized, on some IaaS, or baremetal ...)
  - platform: what target host runs (e.g. OS, Distributon, ...); has many providers
  - platform variant: variant of platform (e.g. same platform but based on systemd, or upstart / differ on version)
  - provider: provides actions.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/infra_operator.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

