# ActiveInteraction

Manage application specific business logic.

Inspired by [Mutations][].

## Installation

Add this line to your application's Gemfile:

```rb
gem 'active_interaction', '~> 0.1.0'

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

[mutations]: https://github.com/cypriss/mutations
