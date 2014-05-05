# [ActiveInteraction][0]

[![Gem Version][1]][2]
[![Build Status][3]][4]
[![Coverage Status][5]][6]
[![Code Climate][7]][8]
[![Dependency Status][9]][10]

At first it seemed alright. A little business logic in a controller
or model wasn't going to hurt anything. Then one day you wake up
and you're surrounded by fat models and unwieldy controllers. Curled
up and crying in the corner, you can't help but wonder how it came
to this.

Take back control. Slim down models and wrangle monstrous controller
methods with ActiveInteraction.

Read more on the [project page][11] or check out the full [documentation][12]
on RubyDoc.info.

- [Installation](#installation)
- [Basic Usage](#basic-usage)
  - [What do I get?](#what-do-i-get)
  - [How do I call an interaction?](#how-do-i-call-an-interaction)
  - [What can I pass to an interaction?](#what-can-i-pass-to-an-interaction)
  - [How do I define an interaction?](#how-do-i-define-an-interaction)
- [Filters](#filters)
  - [Array](#array)
  - [Boolean](#boolean)
  - [Date](#date)
  - [DateTime](#datetime)
  - [Decimal](#decimal)
  - [File](#file)
  - [Float](#float)
  - [Hash](#hash)
  - [Integer](#integer)
  - [Model](#model)
  - [String](#string)
  - [Symbol](#symbol)
  - [Time](#time)
- [Advanced Usage](#advanced-usage)
  - [Composition](#composition)
  - [Transactions](#transactions)
  - [Translation](#translation)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

## Installation

This project uses [semantic versioning][13].

Add it to your Gemfile:

```ruby
gem 'active_interaction', '~> 1.2'
```

And then execute:

```sh
$ bundle
```

Or install it yourself with:

```sh
$ gem install active_interaction
```

## Basic Usage

### What do I get?

ActiveInteraction::Base lets you create interaction models. These
models ensure that certain inputs are provided and that those
inputs are in the format you want them in. If the inputs are valid
it will call `execute`, store the return value of that method in
`result`, and return an instance of your ActiveInteraction::Base
subclass. Let's look at a simple example:

```ruby
# Define an interaction that signs up a user.
class UserSignup < ActiveInteraction::Base
  # required
  string :email, :name

  # optional
  boolean :newsletter_subscribe, default: nil

  # ActiveRecord validations
  validates :email, format: EMAIL_REGEX

  # The execute method is called only if the inputs validate. It
  # does your business action. The return value will be stored in
  # `result`.
  def execute
    user = User.create!(email: email, name: name)
    if newsletter_subscribe
      NewsletterSubscriptions.create(email: email, user_id: user.id)
    end
    UserMailer.async(:deliver_welcome, user.id)
    user
  end
end

# In a controller action (for instance), you can run it:
def new
  @signup = UserSignup.new
end

def create
  @signup = UserSignup.run(params[:user])

  # Then check to see if it worked:
  if @signup.valid?
    redirect_to welcome_path(user_id: signup.result.id)
  else
    render action: :new
  end
end
```

You may have noticed that ActiveInteraction::Base quacks like
ActiveRecord::Base. It can use validations from your Rails application
and check option validity with `valid?`. Any errors are added to
`errors` which works exactly like an ActiveRecord model. By default,
everything within the `execute` method is run in a transaction if
ActiveRecord is available.

### How do I call an interaction?

There are two way to call an interaction. Given UserSignup, you can
do this:

```ruby
outcome = UserSignup.run(params)
if outcome.valid?
  # Do something with outcome.result...
else
  # Do something with outcome.errors...
end
```

Or, you can do this:

```ruby
result = UserSignup.run!(params)
# Either returns the result of execute,
# or raises ActiveInteraction::InvalidInteractionError
```

### What can I pass to an interaction?

Interactions only accept a Hash for `run` and `run!`.

```ruby
# A user comments on an article
class CreateComment < ActiveInteraction::Base
  model :article, :user
  string :comment

  validates :comment, length: { maximum: 500 }

  def execute; ...; end
end

def somewhere
  outcome = CreateComment.run(
    comment: params[:comment],
    article: Article.find(params[:article_id]),
    user: current_user
  )
end
```

### How do I define an interaction?

1. Subclass ActiveInteraction::Base

    ```ruby
    class YourInteraction < ActiveInteraction::Base
      # ...
    end
    ```

2. Define your attributes:

    ```ruby
    string :name, :state
    integer :age
    boolean :is_special
    model :account
    array :tags, default: nil do
      string
    end
    hash :prefs, default: nil do
      boolean :smoking
      boolean :view
    end
    date :arrives_on, default: -> { Date.current }
    date :departs_on, default: -> { Date.tomorrow }
    ```

3. Use any additional validations you need:

    ```ruby
    validates :name, length: { maximum: 10 }
    validates :state, inclusion: { in: %w(AL AK AR ... WY) }
    validate :arrives_before_departs

    private

    def arrive_before_departs
      if departs_on <= arrives_on
        errors.add(:departs_on, 'must come after the arrival time')
      end
    end
    ```

4. Define your execute method. It can return whatever you like:

    ```ruby
    def execute
      record = do_thing(...)
      # ...
      record
    end
    ```

Check out the [documentation][12] for a full list of methods.

## Filters

### Array

### Boolean

``` rb
class BooleanInteraction < ActiveInteraction::Base
  boolean :kool_aid

  def execute
    'Oh yeah!' if kool_aid
  end
end

BooleanInteraction.run(kool_aid: 1).errors.messages[:kool_aid]
# => ["is not a valid boolean"]
BooleanInteraction.run(kool_aid: true).result
# => "Oh yeah!"
```

### Date

``` rb
class DateInteraction < ActiveInteraction::Base
  date :birthday

  def execute
    birthday + (18 * 365)
  end
end

DateInteraction.run(birthday: 'yesterday').errors.messages[:birthday]
# => ["is not a valid date"]
DateInteraction.run(birthday: Date.new(1989, 9, 1)).result
# => #<Date: 2007-08-28 ((2454341j,0s,0n),+0s,2299161j)>
```

### DateTime

``` rb
class DateTimeInteraction < ActiveInteraction::Base
  date_time :now

  def execute
    now.iso8601
  end
end

DateTimeInteraction.run(now: 'now').errors.messages[:now]
# => ["is not a valid date time"]
DateTimeInteraction.run(now: DateTime.now).result
# => "2014-05-05T19:49:24+00:00"
```

### Decimal

``` rb
class DecimalInteraction < ActiveInteraction::Base
  decimal :price

  def execute
    price * 1.0825
  end
end

DecimalInteraction.run(price: 'a lot').errors.messages[:price]
# => ["is not a valid decimal"]
DecimalInteraction.run(price: BigDecimal.new('0.99')).result
# => #<BigDecimal:7f3f7a188cb8,'0.1071675E1',18(36)>
```

### File

### Float

### Hash

### Integer

### Model

### String

### Symbol

### Time

## Advanced Usage

### Composition

You can run interactions from within other interactions by calling `compose`.
If the interaction is successful, it'll return the result (just like if you had
called it with `run!`). If something went wrong, execution will halt
immediately and the errors will be moved onto the caller.

```ruby
class AddThree < ActiveInteraction::Base
  integer :x
  def execute
    compose(Add, x: x, y: 3)
  end
end
AddThree.run!(x: 5)
# => 8
```

To bring in filters from another interaction, use `import_filters`. Combined
with `inputs`, delegating to another interaction is a piece of cake.

```ruby
class AddAndDouble < ActiveInteraction::Base
  import_filters Add
  def execute
    compose(Add, inputs) * 2
  end
end
```

### Transactions

By default, every interaction is run inside a transaction if ActiveRecord is
available.

``` rb
class TransactionalInteraction < ActiveInteraction::Base
  def execute
    puts 'Transactional!'
  end
end

ActiveRecord::Base.logger = Logger.new(STDOUT)
TransactionalInteraction.run!
# D, [2014-05-04T22:30:25.842310 #2172] DEBUG -- :    (0.2ms)  begin transaction
# Transactional!
# D, [2014-05-04T22:30:25.843563 #2172] DEBUG -- :    (0.1ms)  commit transaction
```

You can disable this behavior using the `transaction` class method.

``` rb
class NotTransactionalInteraction < ActiveInteraction::Base
  transaction false

  def execute
    puts 'Not transactional!'
  end
end

NotTransactionalInteraction.run!
# Not transactional!
```

You can also customize the transaction with the `transaction` class method. Any
options will be passed through to ActiveRecord.

``` rb
class CustomTransactionalInteraction < ActiveInteraction::Base
  transaction true,
    isolation: :serializable,
    joinable: true,
    requires_new: true
end
```

### Translation

ActiveInteraction is i18n aware out of the box! All you have to do is add
translations to your project. In Rails, these typically go into
`config/locales`. For example, let's say that for some reason you want to
print everything out backwards. Simply add translations for ActiveInteraction
to your `hsilgne` locale.

``` yml
# config/locales/hsilgne.yml
hsilgne:
  active_interaction:
    types:
      array: yarra
      boolean: naeloob
      date: etad
      date_time: emit etad
      decimal: lamiced
      file: elif
      float: taolf
      hash: hsah
      integer: regetni
      model: ledom
      string: gnirts
      symbol: lobmys
      time: emit
    errors:
      messages:
        invalid: dilavni si
        invalid_nested: (%{value} <= %{name}) eulav detsen dilavni na sah
        invalid_type: '%{type} dilav a ton si'
        missing: deriuqer si
```

Then set your locale and run interactions like normal.

``` rb
class I18nInteraction < ActiveInteraction::Base
  string :name
end

I18nInteraction.run(name: false).errors.messages[:name]
# => ["is not a valid string"]

I18n.locale = :hsilgne
I18nInteraction.run(name: false).errors.messages[:name]
# => ["gnirts dilav a ton si"]
```

## Changelog

See [CHANGELOG.md][19] for details.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md][20] for details on
how to get started.

## Credits

ActiveInteraction is brought to you by [@AaronLasseigne][14] and
[@tfausak][15] from [@orgsync][16]. We were inspired by the fantastic
work done in [Mutations][17]. A full list of contributers can be found
[here][21].

## License

See [LICENSE.txt][18] for details.

  [0]: https://github.com/orgsync/active_interaction
  [1]: https://badge.fury.io/rb/active_interaction.svg
  [2]: https://badge.fury.io/rb/active_interaction "Gem Version"
  [3]: https://travis-ci.org/orgsync/active_interaction.svg?branch=master
  [4]: https://travis-ci.org/orgsync/active_interaction "Build Status"
  [5]: https://coveralls.io/repos/orgsync/active_interaction/badge.png?branch=master
  [6]: https://coveralls.io/r/orgsync/active_interaction?branch=master "Coverage Status"
  [7]: https://codeclimate.com/github/orgsync/active_interaction.png
  [8]: https://codeclimate.com/github/orgsync/active_interaction "Code Climate"
  [9]: https://gemnasium.com/orgsync/active_interaction.svg
  [10]: https://gemnasium.com/orgsync/active_interaction "Dependency Status"
  [11]: http://orgsync.github.io/active_interaction/
  [12]: http://rubydoc.info/github/orgsync/active_interaction
  [13]: http://semver.org/spec/v2.0.0.html
  [14]: https://github.com/AaronLasseigne
  [15]: https://github.com/tfausak
  [16]: https://github.com/orgsync
  [17]: https://github.com/cypriss/mutations
  [18]: LICENSE.txt
  [19]: CHANGELOG.md
  [20]: CONTRIBUTING.md
  [21]: https://github.com/orgsync/active_interaction/graphs/contributors
