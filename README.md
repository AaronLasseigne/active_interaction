# ActiveInteraction

[![Gem Version][]](https://badge.fury.io/rb/active_interaction)
[![Build Status][]](https://travis-ci.org/orgsync/active_interaction)
[![Coverage Status][]](https://coveralls.io/r/orgsync/active_interaction)
[![Code Climate][]](https://codeclimate.com/repos/51dc5784c7f3a37a72000019/feed)
[![Dependency Status][]](https://gemnasium.com/orgsync/active_interaction)

Manage application specific business logic.

Inspired by [Mutations][].

## Installation

Add this line to your application's Gemfile:

```rb
gem 'active_interaction', '~> 0.1.0'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install active_interaction
```

## Usage

```rb
class ExampleInteraction < ActiveInteraction::Base
  # Required
  integer :a

  # Optional
  integer :b, allow_nil: true

  def execute
    b.nil? ? a : a + b
  end
end

outcome = ExampleInteraction.run(a: 1, b: 2)
if outcome.valid?
  p outcome.response
else
  p outcome.errors
end
```

[build status]: https://travis-ci.org/orgsync/active_interaction.png
[code climate]: https://codeclimate.com/repos/51dc5784c7f3a37a72000019/badges/bd2ae2bc5f9a707b9008/gpa.png
[coverage status]: https://coveralls.io/repos/orgsync/active_interaction/badge.png
[dependency status]: https://gemnasium.com/orgsync/active_interaction.png
[gem version]: https://badge.fury.io/rb/active_interaction.png
[mutations]: https://github.com/cypriss/mutations
