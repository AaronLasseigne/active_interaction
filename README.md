# ActiveInteraction [![][1]][2] [![][3]][4] [![][5]][6]

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

[1]: https://travis-ci.org/orgsync/active_interaction.png
[2]: https://travis-ci.org/orgsync/active_interaction
[3]: https://gemnasium.com/orgsync/active_interaction.png
[4]: https://gemnasium.com/orgsync/active_interaction
[5]: https://codeclimate.com/repos/51dc5784c7f3a37a72000019/badges/bd2ae2bc5f9a707b9008/gpa.png
[6]: https://codeclimate.com/repos/51dc5784c7f3a37a72000019/feed
[mutations]: https://github.com/cypriss/mutations
