# ActiveInteraction

[![Gem Version][]](https://badge.fury.io/rb/active_interaction)
[![Build Status][]](https://travis-ci.org/orgsync/active_interaction)
[![Coverage Status][]](https://coveralls.io/r/orgsync/active_interaction)
[![Code Climate][]](https://codeclimate.com/github/orgsync/active_interaction)
[![Dependency Status][]](https://gemnasium.com/orgsync/active_interaction)

Manage application specific business logic.

Inspired by [Mutations][].

This project uses [semantic versioning][].

## Installation

Add this line to your application's Gemfile:

    gem 'active_interaction', '~> 0.1.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_interaction

## Usage

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

[build status]: https://travis-ci.org/orgsync/active_interaction.png
[code climate]: https://codeclimate.com/github/orgsync/active_interaction.png
[coverage status]: https://coveralls.io/repos/orgsync/active_interaction/badge.png
[dependency status]: https://gemnasium.com/orgsync/active_interaction.png
[gem version]: https://badge.fury.io/rb/active_interaction.png
[mutations]: https://github.com/cypriss/mutations
[semantic versioning]: http://semver.org
