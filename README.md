<p align="center">
  <img alt="" src="https://a.pomf.se/frhpuf.svg">
</p>

<h1 align="center">
  <a href="https://github.com/orgsync/active_interaction">
    ActiveInteraction
  </a>
</h1>

<p align="center">
  ActiveInteraction manages application-specific business logic.
  It's an implementation of the command pattern in Ruby.
</p>

<p align="center">
  <a href="https://rubygems.org/gems/active_interaction">
    <img alt="" src="https://img.shields.io/gem/v/active_interaction.svg">
  </a>
  <a href="https://travis-ci.org/orgsync/active_interaction">
    <img alt="" src="https://img.shields.io/travis/orgsync/active_interaction/master.svg">
  </a>
  <a href="https://coveralls.io/r/orgsync/active_interaction">
    <img alt="" src="https://img.shields.io/coveralls/orgsync/active_interaction/master.svg">
  </a>
  <a href="https://codeclimate.com/github/orgsync/active_interaction">
    <img alt="" src="https://img.shields.io/codeclimate/github/orgsync/active_interaction.svg">
  </a>
  <a href="https://gemnasium.com/orgsync/active_interaction">
    <img alt="" src="https://img.shields.io/gemnasium/orgsync/active_interaction.svg">
  </a>
</p>

<hr>

ActiveInteraction gives you a place to put your business logic. It also helps
you write safer code by validating that your inputs conform to your
expectations. If ActiveModel deals with your nouns, then ActiveInteraction
handles your verbs.

Read more on [the project page][] or check out [the full documentation][].

- [Installation](#installation)
- [Basic usage](#basic-usage)
  - [Rails](#rails)
- [Filters](#filters)
  - [Array](#array)
  - [Boolean](#boolean)
  - [Decimal](#decimal)
  - [File](#file)
  - [Hash](#hash)
  - [Interface](#interface)
  - [Model](#model)
  - [String](#string)
  - [Symbol](#symbol)
  - [Dates and times](#dates-and-times)
    - [Date](#date)
    - [Date and time](#date-and-time)
    - [Time](#time)
  - [Numbers](#numbers)
    - [Float](#float)
    - [Integer](#integer)
- [Advanced usage](#advanced-usage)
  - [Callbacks](#callbacks)
  - [Composition](#composition)
  - [Symbolic errors](#symbolic-errors)
  - [Translations](#translations)
  - [Validations](#validations)
- [Credits](#credits)

## Installation

Add it to your Gemfile:

``` rb
gem 'active_interaction', '~> 1.5'
```

Or install it manually:

``` sh
$ gem install active_interaction --version '~> 1.5'
```

This project uses [Semantic Versioning][]. Check out [the change log][] for a
detailed list of changes.

ActiveInteraction works will all supported versions of Ruby (2.0 through 2.2)
and ActiveModel (3.2 through 4.2).

## Basic usage

``` rb
require 'active_interaction'

class Square < ActiveInteraction::Base
  float :x

  def execute
    x**2
  end
end
```

``` rb
outcome = Square.run(x: 'two point three')
outcome.valid?
# => nil
outcome.errors.messages
# => {:x=>["is not a valid float"]}

outcome = Square.run(x: 2.3)
outcome.valid?
# => true
outcome.result
# => 5.289999999999999
```

``` rb
Square.run!(x: 'two point three')
# ActiveInteraction::InvalidInteractionError: X is not a valid float

Square.run!(x: 2.3)
# => 5.289999999999999
```

### Rails

## Filters

### Array

### Boolean

### Decimal

### File

### Hash

### Interface

### Model

### String

### Symbol

### Dates and times

#### Date

#### Date and time

#### Time

### Numbers

#### Float

#### Integer

## Advanced usage

### Callbacks

### Composition

### Symbolic errors

### Translations

### Validation

## Credits

ActiveInteraction is brought to you by [Aaron Lasseigne][] and
[Taylor Fausak][] from [OrgSync][]. We were inspired by the fantastic work done
by [Jonathan Novak][] on [Mutations][].

If you want to contribute to ActiveInteraction, please read
[our contribution guidelines][]. A [complete list of contributors][] is
available on GitHub.

ActiveInteraction is licensed under [the MIT License][].

Logo provided free by [Emoji One][].

[the project page]: http://orgsync.github.io/active_interaction/
[the full documentation]: http://rubydoc.info/github/orgsync/active_interaction
[semantic versioning]: http://semver.org/spec/v2.0.0.html
[the changelog]: CHANGELOG.md
[aaron lasseigne]: https://github.com/AaronLasseigne
[taylor fausak]: https://github.com/tfausak
[orgsync]: https://github.com/orgsync
[jonathan novak]: https://github.com/cypriss
[mutations]: https://github.com/cypriss/mutations
[our contribution guidelines]: CONTRIBUTING.md
[complete list of contributors]: https://github.com/orgsync/active_interaction/graphs/contributors
[the mit license]: LICENSE.txt
[emoji one]: http://emojione.com/
