<p align="center">
  <img alt="briefcase" src="briefcase.png">
</p>

<h1 align="center">ActiveInteraction</h1>

<p align="center">Manage application specific business logic.</p>

<p align="center"> 
  <a href="https://rubygems.org/gems/active_interaction">
    <img alt="Gem Version" src="https://img.shields.io/gem/v/active_interaction.svg?style=flat">
  </a>
  <a href="https://travis-ci.org/orgsync/active_interaction">
    <img alt="Build Status" src="https://img.shields.io/travis/orgsync/active_interaction/master.svg?style=flat">
  </a>
  <a href="https://coveralls.io/r/orgsync/active_interaction?branch=master">
    <img alt="Coverage Status" src="https://img.shields.io/coveralls/orgsync/active_interaction/master.svg?style=flat">
  </a>
  <a href="https://codeclimate.com/github/orgsync/active_interaction">
    <img alt="Code Climate" src="https://img.shields.io/codeclimate/github/orgsync/active_interaction.svg?style=flat">
  </a>
  <a href="https://gemnasium.com/orgsync/active_interaction">
    <img alt="Dependency Status" src="https://img.shields.io/gemnasium/orgsync/active_interaction.svg?style=flat">
  </a>

  <hr>
</p>

At first it seemed alright. A little business logic in a controller
or model wasn't going to hurt anything. Then one day you wake up
and you're surrounded by fat models and unwieldy controllers. Curled
up and crying in the corner, you can't help but wonder how it came
to this.

Take back control. Slim down models and wrangle monstrous controller
methods with ActiveInteraction.

Read more on the [project page][1] or check out the full [documentation][2]
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
  - [Interface](#interface)
  - [Model](#model)
  - [String](#string)
  - [Symbol](#symbol)
  - [Time](#time)
- [Advanced Usage](#advanced-usage)
  - [Composition](#composition)
  - [Symbolic Errors](#symbolic-errors)
  - [Translation](#translation)
- [Credits](#credits)

## Installation

This project uses [semantic versioning][3].

Add it to your Gemfile:

``` ruby
gem 'active_interaction', '~> 2.0'
```

And then execute:

``` sh
$ bundle
```

Or install it yourself with:

``` sh
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

``` ruby
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
`errors` which works exactly like an ActiveRecord model.

### How do I call an interaction?

There are two way to call an interaction. Given UserSignup, you can
do this:

``` ruby
outcome = UserSignup.run(params)
if outcome.valid?
  # Do something with outcome.result...
else
  # Do something with outcome.errors...
end
```

Or, you can do this:

``` ruby
result = UserSignup.run!(params)
# Either returns the result of execute,
# or raises ActiveInteraction::InvalidInteractionError
```

### What can I pass to an interaction?

Interactions only accept a Hash for `run` and `run!`.

``` ruby
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

    ``` ruby
    class YourInteraction < ActiveInteraction::Base
      # ...
    end
    ```

2. Define your attributes:

    ``` ruby
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

    [A full list of attribute filters can be found below.](#filters)

3. Use any additional validations you need:

    ``` ruby
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

    ``` ruby
    def execute
      record = do_thing(...)
      # ...
      record
    end
    ```

Check out the [documentation][12] for a full list of methods.

## Filters

#### Valid Inputs

All filters accept their native type and typically a narrow set of
alternatives to coerce based on Rails parameter values.

#### Filter Parameters

- **attributes** (`Array<Symbol>`) - Attributes to create.
- **options** (`Hash{Symbol => Object}`) (defaults to: `{}`)
  - `:default` (`Object`) - Fallback value if `nil` is given. May be set to
                            `nil` to make a filter optional.
  - `:desc` (`String`) - Human-readable description of this input.

```ruby
class Interaction < ActiveInteraction::Base
  string :a, :b,
    default: '',
    desc: 'Strings!'

  def execute
    puts a
    puts b
  end
end
```

### Array

#### Additional Valid Inputs

ActiveRecord::Relation objects passed in will be converted to Arrays.

#### Additional Parameters

- **block** (`Proc`) - Filter method to apply to each element of the Array.

#### Modified Filter Options

- `:default` (`[]` or `nil`) - Fallback value if `nil` is given. May be set
                               to `nil` to make the filter optional. If an
                               empty Array is given the defaults inside the
                               block will be used.

#### Examples

```ruby
class ArrayInteraction < ActiveInteraction::Base
  array :toppings

  def execute
    toppings.length
  end
end

ArrayInteraction.run(toppings: 'everything').errors.messages[:toppings]
# => ["is not a valid array"]
ArrayInteraction.run(toppings: [:cheese, 'pepperoni']).result
# => 2
```

An `Array` of `Date`s with a particular format:

```ruby
array :birthdays do
  date format: '%Y-%m-%d'
end
```

### Boolean

#### Additional Valid Inputs

The strings `"1"` and `"true"` (case-insensitive) are converted to `true`
while the strings `"0"` and `"false"` (case-insensitive) are converted to
`false`.

#### Example

```ruby
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

#### Additional Valid Inputs

String values are processed using `parse` unless the `:format` option is given,
in which case they will be processed with `strptime`.

#### Additional Filter Options

- `:format` (`String`) - A template for parsing the date `String` that matches
                         the format passed to `strptime`.

#### Example

```ruby
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

A formatted date:

```ruby
date :birthday, format: '%m-%d-%Y'
```

### DateTime

#### Additional Valid Inputs

String values are processed using `parse` unless the `:format` option is given,
in which case they will be processed with `strptime`.

#### Additional Filter Options

- `:format` (`String`) - A template for parsing the date and time `String`
                         that matches the format passed to `strptime`.

#### Example

```ruby
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

A formatted date and time:

```ruby
date_time :start_date, format: '%Y-%m-%dT%H:%M:%SZ'
```

### Decimal

#### Additional Valid Inputs

Numerics and String values will be converted.

#### Additional Filter Options

- `:digits` (`Fixnum`) - The number of significant digits. If omitted or 0,
                         the number of significant digits is determined from
                         the initial value.

#### Example

```ruby
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

Having 4 significant digits:

```ruby
decimal :roughly, digits: 4
```

### File

#### Additional Valid Inputs

Tempfile and anything that responds to `tempfile` with a File or Tempfile.
This means that file uploads via forms in Rails `params` can be directly
passed in.

#### Example

```ruby
class FileInteraction < ActiveInteraction::Base
  file :readme

  def execute
    readme.size
  end
end

FileInteraction.run(readme: 'please').errors.messages[:readme]
# => ["is not a valid file"]
FileInteraction.run(readme: File.open('README.md')).result
# => 12947
```

### Float

#### Additional Valid Inputs

Numerics and String values will be converted.

#### Example

```ruby
class FloatInteraction < ActiveInteraction::Base
  float :n

  def execute
    n**2
  end
end

FloatInteraction.run(n: 'three').errors.messages[:n]
# => ["is not a valid float"]
FloatInteraction.run(n: 3.0).result
# => 9.0
```

### Hash

Hashes are converted to `ActiveSupport::HashWithIndifferentAccess`.

#### Additional Parameters

- **block** (`Proc`) - Filter methods to apply for select keys.

#### Modified Filter Options

- `:default` (`{}` or `nil`) - Fallback value if `nil` is given. May be set
                               to `nil` to make the filter optional. If an
                               empty Hash is given the defaults inside the
                               block will be used.

#### Additional Filter Options

- `:strip` (`Boolean`) - default: `true` - Remove unknown keys.

#### Example

```ruby
class HashInteraction < ActiveInteraction::Base
  hash :options do
    boolean :fuzzy
    integer :count, default: 1
  end

  def execute
    options.merge(a: true)
  end
end

HashInteraction.run(options: 'none').errors.messages[:options]
# => ["is not a valid hash"]
HashInteraction.run(options: {}).errors.messages[:options]
# => ["has an invalid nested value (\"fuzzy\" => nil)"]
HashInteraction.run(options: {fuzzy: true}).result
# => {:fuzzy=>true, :count=>1, :a=>true}
```

Allow all keys:

```ruby
hash :wildcards, strip: false
```

### Integer

#### Additional Valid Inputs

Numerics and String values will be converted.

#### Example

```ruby
class IntegerInteraction < ActiveInteraction::Base
  integer :limit

  def execute
    limit.downto(0).to_a
  end
end

IntegerInteraction.run(limit: 'ten').errors.messages[:limit]
# => ["is not a valid integer"]
IntegerInteraction.run(limit: 10).result
# => [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
```

### Interface

#### Additional Filter Options

- `:methods` (`Array<String,Symbol>`) - default: `[]` - The methods that objects conforming to this interface
                                                        should respond to.

#### Example

```ruby
class InterfaceInteraction < ActiveInteraction::Base
  hash :data,
    strip: false
  interface :serializer,
    methods: [:dump]

  def execute
    serializer.dump(data)
  end
end

require 'yaml'
InterfaceInteraction.run(data: {one: 1}, serializer: Object).errors.messages[:serializer]
# => ["is not a valid interface"]
InterfaceInteraction.run(data: {one: 1}, serializer: YAML).result
# => "--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\none: 1\n"
```

### Model

#### Additional Filter Options

- `:class` (`Class`, `String`, `Symbol`) - default: the attribute name - Ensures the object passed matches
                                                                         the class using `is_a?` or `===`.
                                                                         If a String or Symbol is provided
                                                                         it will have `classify` called on
                                                                         it. *Note: Modules included are
                                                                         part of the ancestry of a class and
                                                                         can also be matched against.*


#### Example

```ruby
class ModelInteraction < ActiveInteraction::Base
  model :logger

  def execute
    logger.debug('Executing...')
  end
end

ModelInteraction.run(logger: 'lumberjack').errors.messages[:logger]
# => ["is not a valid model"]
ModelInteraction.run(logger: Logger.new(STDOUT))
# D, [2014-05-28T19:53:51.814709 #1965] DEBUG -- : Executing...
```

An object which is a `User` or a subclass of `User`:

```ruby
model :creator, class: User
```

### String

#### Additional Filter Options

- `:strip` (`Boolean`) - default: `true` - Strip leading and trailing whitespace.

#### Example

```ruby
class StringInteraction < ActiveInteraction::Base
  string :name

  def execute
    name.upcase
  end
end

StringInteraction.run(name: 0xdeadbeef).errors.messages[:name]
# => ["is not a valid string"]
StringInteraction.run(name: 'taylor').result
# => "TAYLOR"
```

### Symbol

#### Additional Valid Inputs

String values will be converted.

#### Example

```ruby
class SymbolInteraction < ActiveInteraction::Base
  symbol :method

  def execute
    method.to_proc
  end
end

SymbolInteraction.run(method: -> {}).errors.messages[:method]
# => ["is not a valid symbol"]
SymbolInteraction.run(method: :object_id).result
# => #<Proc:0x007f1c6a6d7a58>
```

### Time

#### Additional Valid Inputs

Numeric values are processed using `at`. Strings are processed using `parse`
unless the format option is given, in which case they will be processed with
`strptime`. If `Time.zone` is available it will be used so that the values are
time zone aware.

#### Additional Filter Options

- `:format` (`String`) - A template for parsing the date `String` that matches
                         the format passed to `strptime`. This is not available
                         for `ActiveSupport::TimeZone` objects.

#### Example

```ruby
class TimeInteraction < ActiveInteraction::Base
  time :epoch

  def execute
    Time.now - epoch
  end
end

TimeInteraction.run(epoch: 'a long, long time ago').errors.messages[:epoch]
# => ["is not a valid time"]
TimeInteraction.run(epoch: Time.new(1970)).result
# => 1401307376.3133254
```

A formatted time:

```ruby
time :start_date, format: '%Y-%m-%dT%H:%M:%S%Z'
```

## Advanced Usage

### Composition

You can run interactions from within other interactions by calling `compose`.
If the interaction is successful, it'll return the result (just like if you had
called it with `run!`). If something went wrong, execution will halt
immediately and the errors will be moved onto the caller.

``` ruby
class Add < ActiveInteraction::Base
  integer :x, :y
  def execute
    x + y
  end
end

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

``` ruby
class AddAndDouble < ActiveInteraction::Base
  import_filters Add
  def execute
    compose(Add, inputs) * 2
  end
end
```

### Symbolic Errors

ActiveInteraction provides symbolic errors for easier introspection and testing
of errors. Symbolic errors improve on regular errors by adding a symbol that
represents the type of error that has occurred. Let's look at an example where
an item is purchased using a credit card.

```ruby
class BuyItem < ActiveInteraction::Base
  model :credit_card, :item
  hash :options do
    boolean :gift_wrapped
  end

  def execute
    order = credit_card.purchase(item)

    notify(credit_card.account)

    order
  end

  def notify(account)
    # ...
  end
end
```

Having missing or invalid inputs causes the interaction to fail and return
errors.

```ruby
> outcome = BuyItem.run({item: 'Thing', options: {gift_wrapped: 'yes'}})
> outcome.errors.messages
# => {:credit_card=>["is required"], :item=>["is not a valid model"], :options=>["has an invalid nested value (\"gift_wrapped\" => \"yes\")"]}
```

Determining the type of error based on the string is difficult if not
impossible. Calling `symbolic` instead of `messages` on `errors` gives
you the same list of errors with a testable label representing the error.

```ruby
> outcome.errors.symbolic
# => {"credit_card"=>[:missing], "item"=>[:invalid_type], "options"=>[:invalid_nested]}
```

Symbolic errors can also be manually added during the `execute` call by
calling `add_sym` instead of `add` on `errors`. It works the same way as
`add` except that the second argument is the error label.

```ruby
def execute
  errors.add_sym(:monster, :no_passage, 'You shall not pass!')
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
      interface: ecafretni
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

``` ruby
class I18nInteraction < ActiveInteraction::Base
  string :name
end

I18nInteraction.run(name: false).errors.messages[:name]
# => ["is not a valid string"]

I18n.locale = :hsilgne
I18nInteraction.run(name: false).errors.messages[:name]
# => ["gnirts dilav a ton si"]
```

## Credits

ActiveInteraction is brought to you by [@AaronLasseigne][4] and
[@tfausak][5] from [@orgsync][6]. We were inspired by the fantastic
work done in [Mutations][7]. A full list of contributers can be found
[here][8].

Logo provided free by [Emoji One][9].

  [1]: http://orgsync.github.io/active_interaction/
  [2]: http://rubydoc.info/github/orgsync/active_interaction
  [3]: http://semver.org/spec/v2.0.0.html
  [4]: https://github.com/AaronLasseigne
  [5]: https://github.com/tfausak
  [6]: https://github.com/orgsync
  [7]: https://github.com/cypriss/mutations
  [8]: https://github.com/orgsync/active_interaction/graphs/contributors
  [9]: http://emojione.com/
