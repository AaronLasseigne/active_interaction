# [ActiveInteraction][]

ActiveInteraction manages application-specific business logic.
It's an implementation of the command pattern in Ruby.

[![Version](https://img.shields.io/gem/v/active_interaction.svg?style=flat-square)](https://rubygems.org/gems/active_interaction)
[![Build](https://img.shields.io/travis/AaronLasseigne/active_interaction.svg?style=flat-square)](https://travis-ci.org/AaronLasseigne/active_interaction)
[![Coverage](https://img.shields.io/coveralls/github/AaronLasseigne/active_interaction.svg?style=flat-square)](https://coveralls.io/r/orgsync/active_interaction)
[![Climate](https://img.shields.io/codeclimate/maintainability/orgsync/active_interaction.svg?style=flat-square)](https://codeclimate.com/github/orgsync/active_interaction)

---

ActiveInteraction gives you a place to put your business logic. It also helps
you write safer code by validating that your inputs conform to your
expectations. If ActiveModel deals with your nouns, then ActiveInteraction
handles your verbs.

- [Installation](#installation)
- [Basic usage](#basic-usage)
  - [Validations](#validations)
- [Filters](#filters)
  - [Array](#array)
  - [Boolean](#boolean)
  - [File](#file)
  - [Hash](#hash)
  - [Interface](#interface)
  - [Object](#object)
  - [Record](#record)
  - [String](#string)
  - [Symbol](#symbol)
  - [Dates and times](#dates-and-times)
    - [Date](#date)
    - [DateTime](#datetime)
    - [Time](#time)
  - [Numbers](#numbers)
    - [Decimal](#decimal)
    - [Float](#float)
    - [Integer](#integer)
- [Rails](#rails)
  - [Setup](#setup)
  - [Controller](#controller)
    - [Index](#index)
    - [Show](#show)
    - [New](#new)
    - [Create](#create)
    - [Destroy](#destroy)
    - [Edit](#edit)
    - [Update](#update)
- [Advanced usage](#advanced-usage)
  - [Callbacks](#callbacks)
  - [Composition](#composition)
  - [Defaults](#defaults)
  - [Descriptions](#descriptions)
  - [Errors](#errors)
  - [Forms](#forms)
  - [Grouped inputs](#grouped-inputs)
  - [Optional inputs](#optional-inputs)
  - [Predicates](#predicates)
  - [Translations](#translations)
- [Credits](#credits)

[Full Documentation][]

## Installation

Add it to your Gemfile:

``` rb
gem 'active_interaction', '~> 3.7'
```

Or install it manually:

``` sh
$ gem install active_interaction --version '~> 3.7'
```

This project uses [Semantic Versioning][]. Check out [GitHub releases][] for a
detailed list of changes. For help upgrading to version 2, please read [the
announcement post][].

ActiveInteraction works with Ruby 2.0 through 2.6 and ActiveModel 4.0 through
6.0. If you want to use ActiveInteraction with an older version of Ruby or
ActiveModel, use ActiveInteraction < 3.0.0.

## Basic usage

To define an interaction, create a subclass of `ActiveInteraction::Base`. Then
you need to do two things:

1.  **Define your inputs.** Use class filter methods to define what you expect
    your inputs to look like. For instance, if you need a boolean flag for
    pepperoni, use `boolean :pepperoni`. Check out [the filters
    section](#filters) for all the available options.

2.  **Define your business logic.** Do this by implementing the `#execute`
    method. Each input you defined will be available as the type you specified.
    If any of the inputs are invalid, `#execute` won't be run. Filters are
    responsible for type checking your inputs. Check out [the validations
    section](#validations) if you need more than that.

That covers the basics. Let's put it all together into a simple example that
squares a number.

``` rb
require 'active_interaction'

class Square < ActiveInteraction::Base
  float :x

  def execute
    x**2
  end
end
```

Call `.run` on your interaction to execute it. You must pass a single hash to
`.run`. It will return an instance of your interaction. By convention, we call
this an outcome. You can use the `#valid?` method to ask the outcome if it's
valid. If it's invalid, take a look at its errors with `#errors`. In either
case, the value returned from `#execute` will be stored in `#result`.

``` rb
outcome = Square.run(x: 'two point one')
outcome.valid?
# => nil
outcome.errors.messages
# => {:x=>["is not a valid float"]}

outcome = Square.run(x: 2.1)
outcome.valid?
# => true
outcome.result
# => 4.41
```

You can also use `.run!` to execute interactions. It's like `.run` but more
dangerous. It doesn't return an outcome. If the outcome would be invalid, it
will instead raise an error. But if the outcome would be valid, it simply
returns the result.

``` rb
Square.run!(x: 'two point one')
# ActiveInteraction::InvalidInteractionError: X is not a valid float
Square.run!(x: 2.1)
# => 4.41
```

### Validations

ActiveInteraction type checks your inputs. Often you'll want more than that.
For instance, you may want an input to be a string with at least one
non-whitespace character. Instead of writing your own validation for that, you
can use validations from ActiveModel.

These validations aren't provided by ActiveInteraction. They're from
ActiveModel. You can also use any custom validations you wrote yourself in your
interactions.

``` rb
class SayHello < ActiveInteraction::Base
  string :name

  validates :name,
    presence: true

  def execute
    "Hello, #{name}!"
  end
end
```

When you run this interaction, two things will happen. **First
ActiveInteraction will type check your inputs. Then ActiveModel will validate
them.** If both of those are happy, it will be executed.

``` rb
SayHello.run!(name: nil)
# ActiveInteraction::InvalidInteractionError: Name is required

SayHello.run!(name: '')
# ActiveInteraction::InvalidInteractionError: Name can't be blank

SayHello.run!(name: 'Taylor')
# => "Hello, Taylor!"
```

## Filters

You can define filters inside an interaction using the appropriate class
method. Each method has the same signature:

- Some symbolic names. These are the attributes to create.

- An optional hash of options. Each filter supports at least these two options:

  - `default` is the fallback value to use if `nil` is given. To make a filter
    optional, set `default: nil`.

  - `desc` is a human-readable description of the input. This can be useful for
    generating documentation. For more information about this, read [the
    descriptions section](#descriptions).

- An optional block of sub-filters. Only [array](#array) and [hash](#hash)
  filters support this. Other filters will ignore blocks when given to them.

Let's take a look at an example filter. It defines three inputs: `x`, `y`, and
`z`. Those inputs are optional and they all share the same description ("an
example filter").

``` rb
array :x, :y, :z,
  default: nil,
  desc: 'an example filter' do
    # Some filters support sub-filters here.
  end
```

In general, filters accept values of the type they correspond to, plus a few
alternatives that can be reasonably coerced. Typically the coercions come from
Rails, so `"1"` can be interpreted as the boolean value `true`, the string
`"1"`, or the number `1`.

### Array

In addition to accepting arrays, array inputs will convert
`ActiveRecord::Relation`s into arrays.

``` rb
class ArrayInteraction < ActiveInteraction::Base
  array :toppings

  def execute
    toppings.size
  end
end

ArrayInteraction.run!(toppings: 'everything')
# ActiveInteraction::InvalidInteractionError: Toppings is not a valid array
ArrayInteraction.run!(toppings: [:cheese, 'pepperoni'])
# => 2
```

Use a block to constrain the types of elements an array can contain.

``` rb
array :birthdays do
  date
end
```

Note that you can only have one filter inside an array block, and it must not
have a name.

``` rb
array :cows do
  object class: Cow
end
```

### Boolean

Boolean filters convert the strings `"1"` and `"true"` (case-insensitive) into
`true`. They also convert `"0"` and `"false"` into `false`.

``` rb
class BooleanInteraction < ActiveInteraction::Base
  boolean :kool_aid

  def execute
    'Oh yeah!' if kool_aid
  end
end

BooleanInteraction.run!(kool_aid: 1)
# ActiveInteraction::InvalidInteractionError: Kool aid is not a valid boolean
BooleanInteraction.run!(kool_aid: true)
# => "Oh yeah!"
```

### File

File filters also accept `TempFile`s and anything that responds to `#rewind`.
That means that you can pass the `params` from uploading files via forms in
Rails.

``` rb
class FileInteraction < ActiveInteraction::Base
  file :readme

  def execute
    readme.size
  end
end

FileInteraction.run!(readme: 'README.md')
# ActiveInteraction::InvalidInteractionError: Readme is not a valid file
FileInteraction.run!(readme: File.open('README.md'))
# => 21563
```

### Hash

Hash filters accept hashes. The expected value types are given by passing a
block and nesting other filters. You can have any number of filters inside a
hash, including other hashes.

``` rb
class HashInteraction < ActiveInteraction::Base
  hash :preferences do
    boolean :newsletter
    boolean :sweepstakes
  end

  def execute
    puts 'Thanks for joining the newsletter!' if preferences[:newsletter]
    puts 'Good luck in the sweepstakes!' if preferences[:sweepstakes]
  end
end

HashInteraction.run!(preferences: 'yes, no')
# ActiveInteraction::InvalidInteractionError: Preferences is not a valid hash
HashInteraction.run!(preferences: { newsletter: true, 'sweepstakes' => false })
# Thanks for joining the newsletter!
# => nil
```

Setting default hash values can be tricky. The default value has to be either
`nil` or `{}`. Use `nil` to make the hash optional. Use `{}` if you want to set
some defaults for values inside the hash.

``` rb
hash :optional,
  default: nil
# => {:optional=>nil}

hash :with_defaults,
  default: {} do
    boolean :likes_cookies,
      default: true
  end
# => {:with_defaults=>{:likes_cookies=>true}}
```

By default, hashes remove any keys that aren't given as nested filters. To
allow all hash keys, set `strip: false`. In general we don't recommend doing
this, but it's sometimes necessary.

``` rb
hash :stuff,
  strip: false
```

### Interface

Interface filters allow you to specify that an object must respond to a certain
set of methods. This allows you to do duck typing with interactions.

``` rb
class InterfaceInteraction < ActiveInteraction::Base
  interface :serializer,
    methods: %i[dump load]

  def execute
    input = '{ "is_json" : true }'
    object = serializer.load(input)
    output = serializer.dump(object)

    output
  end
end

require 'json'

InterfaceInteraction.run!(serializer: Object.new)
# ActiveInteraction::InvalidInteractionError: Serializer is not a valid interface
InterfaceInteraction.run!(serializer: JSON)
# => "{\"is_json\":true}"
```

### Object

Object filters allow you to require an instance of a particular class. It
checks either `#is_a?` on the instance or `.===` on the class. Because of that,
it also works with classes that have mixed modules in with `include`.

``` rb
class Cow
  def moo
    'Moo!'
  end
end

class ObjectInteraction < ActiveInteraction::Base
  object :cow

  def execute
    cow.moo
  end
end

ObjectInteraction.run!(cow: Object.new)
# ActiveInteraction::InvalidInteractionError: Cow is not a valid object
ObjectInteraction.run!(cow: Cow.new)
# => "Moo!"
```

The class name is automatically determined by the filter name. If your filter
name is different than your class name, use the `class` option. It can be
either the class, a string, or a symbol.

``` rb
object :dolly1,
  class: Sheep
object :dolly2,
  class: 'Sheep'
object :dolly3,
  class: :Sheep
```

If you have value objects or you would like to build one object from another,
you can use the `converter` option. It is only called if the value provided does
not pass `#is_a?` and `.===` for the object class. The `converter` option
accepts a symbol that specifies a class method on the object class or a proc.
Both will be passed the value and any errors thrown inside the converter will
cause the value to be considered invalid. Any returned value that is not the
correct class will also be treated as invalid. The value given to the `default`
option will also be converted.

``` rb
class ObjectInteraction < ActiveInteraction::Base
  object :ip_address,
    class: IPAddr,
    converter: :new

  def execute
    ip_address
  end
end

ObjectInteraction.run!(ip_address: '192.168.1.1')
# #<IPAddr: IPv4:192.168.1.1/255.255.255.255>

ObjectInteraction.run!(ip_address: 1)
# ActiveInteraction::InvalidInteractionError: Ip address is not a valid object
```

### Record

Record filters allow you to require an instance of a particular class or a value
that can be used to locate an instance of the object. It checks either `#is_a?`
on the instance or `.===` on the class. If the value does not match, it will
call `find` on the class of the record. This is particularly useful when working
with ActiveRecord objects. Like an object filter, the class is derived from the
name passed but can be specified with the `class` option. The value given to the
`default` option will also be found.

``` rb
class RecordInteraction < ActiveInteraction::Base
  record :encoding

  def execute
    encoding
  end
end

> RecordInteraction.run!(encoding: Encoding::US_ASCII)
=> #<Encoding:US-ASCII>

> RecordInteraction.run!(encoding: 'ascii')
=> #<Encoding:US-ASCII>
```

A different method can be specified by providing a symbol to the `finder` option.

### String

String filters define inputs that only accept strings.

``` rb
class StringInteraction < ActiveInteraction::Base
  string :name

  def execute
    "Hello, #{name}!"
  end
end

StringInteraction.run!(name: 0xDEADBEEF)
# ActiveInteraction::InvalidInteractionError: Name is not a valid string
StringInteraction.run!(name: 'Taylor')
# => "Hello, Taylor!"
```

String filter strips leading and trailing whitespace by default. To disable it, set the
`strip` option to `false`.

``` rb
string :comment,
  strip: false
```

### Symbol

Symbol filters define inputs that accept symbols. Strings will be converted
into symbols.

``` rb
class SymbolInteraction < ActiveInteraction::Base
  symbol :method

  def execute
    method.to_proc
  end
end

SymbolInteraction.run!(method: -> {})
# ActiveInteraction::InvalidInteractionError: Method is not a valid symbol
SymbolInteraction.run!(method: :object_id)
# => #<Proc:0x007fdc9ba94118>
```

### Dates and times

Filters that work with dates and times behave similarly. By default, they all
convert strings into their expected data types using `.parse`. If you give the
`format` option, they will instead convert strings using `.strptime`. Note that
formats won't work with `DateTime` and `Time` filters if a time zone is set.

#### Date

``` rb
class DateInteraction < ActiveInteraction::Base
  date :birthday

  def execute
    birthday + (18 * 365)
  end
end

DateInteraction.run!(birthday: 'yesterday')
# ActiveInteraction::InvalidInteractionError: Birthday is not a valid date
DateInteraction.run!(birthday: Date.new(1989, 9, 1))
# => #<Date: 2007-08-28 ((2454341j,0s,0n),+0s,2299161j)>
```

``` rb
date :birthday,
  format: '%Y-%m-%d'
```

#### DateTime

``` rb
class DateTimeInteraction < ActiveInteraction::Base
  date_time :now

  def execute
    now.iso8601
  end
end

DateTimeInteraction.run!(now: 'now')
# ActiveInteraction::InvalidInteractionError: Now is not a valid date time
DateTimeInteraction.run!(now: DateTime.now)
# => "2015-03-11T11:04:40-05:00"
```

``` rb
date_time :start,
  format: '%Y-%m-%dT%H:%M:%S'
```

#### Time

In addition to converting strings with `.parse` (or `.strptime`), time filters
convert numbers with `.at`.

``` rb
class TimeInteraction < ActiveInteraction::Base
  time :epoch

  def execute
    Time.now - epoch
  end
end

TimeInteraction.run!(epoch: 'a long, long time ago')
# ActiveInteraction::InvalidInteractionError: Epoch is not a valid time
TimeInteraction.run!(epoch: Time.new(1970))
# => 1426068362.5136619
```

``` rb
time :start,
  format: '%Y-%m-%dT%H:%M:%S'
```

### Numbers

All numeric filters accept numeric input. They will also convert strings using
the appropriate method from `Kernel` (like `.Float`).

#### Decimal

``` rb
class DecimalInteraction < ActiveInteraction::Base
  decimal :price

  def execute
    price * 1.0825
  end
end

DecimalInteraction.run!(price: 'one ninety-nine')
# ActiveInteraction::InvalidInteractionError: Price is not a valid decimal
DecimalInteraction.run!(price: BigDecimal(1.99, 2))
# => #<BigDecimal:7fe792a42028,'0.2165E1',18(45)>
```

To specify the number of significant digits, use the `digits` option.

``` rb
decimal :dollars,
  digits: 2
```

#### Float

``` rb
class FloatInteraction < ActiveInteraction::Base
  float :x

  def execute
    x**2
  end
end

FloatInteraction.run!(x: 'two point one')
# ActiveInteraction::InvalidInteractionError: X is not a valid float
FloatInteraction.run!(x: 2.1)
# => 4.41
```

#### Integer

``` rb
class IntegerInteraction < ActiveInteraction::Base
  integer :limit

  def execute
    limit.downto(0).to_a
  end
end

IntegerInteraction.run!(limit: 'ten')
# ActiveInteraction::InvalidInteractionError: Limit is not a valid integer
IntegerInteraction.run!(limit: 10)
# => [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
```

When a `String` is passed into an `integer` input, the value will be coerced.
Coercion is based on `Kernel#Integer` which attempts to detect the base being used.
However, you may want to specify the `base` for the conversion to something more
sensible (e.g. `base: 10`).

``` rb
class IntegerInteraction < ActiveInteraction::Base
  integer :limit1, base: 10
  integer :limit2
  
  def execute
    [limit1, limit2]
  end
end

IntegerInteraction.run!(limit1: "08", limit2: 8)
# => [8, 8]
IntegerInteraction.run!(limit1: "08", limit2: "08")
# ArgumentError: invalid value for Integer(): "08"
```

## Rails

ActiveInteraction plays nicely with Rails. You can use interactions to handle
your business logic instead of models or controllers. To see how it all works,
let's take a look at a complete example of a controller with the typical
resourceful actions.

### Setup

We recommend putting your interactions in `app/interactions`. It's also very
helpful to group them by model. That way you can look in
`app/interactions/accounts` for all the ways you can interact with accounts. In
order to use this structure add
`config.autoload_paths += Dir.glob("#{config.root}/app/interactions/*")` in
your `application.rb`

```
- app/
  - controllers/
    - accounts_controller.rb
  - interactions/
    - accounts/
      - create_account.rb
      - destroy_account.rb
      - find_account.rb
      - list_accounts.rb
      - update_account.rb
  - models/
    - account.rb
  - views/
    - account/
      - edit.html.erb
      - index.html.erb
      - new.html.erb
      - show.html.erb
```

### Controller

#### Index

``` rb
# GET /accounts
def index
  @accounts = ListAccounts.run!
end
```

Since we're not passing any inputs to `ListAccounts`, it makes sense to use
`.run!` instead of `.run`. If it failed, that would mean we probably messed up
writing the interaction.

``` rb
class ListAccounts < ActiveInteraction::Base
  def execute
    Account.not_deleted.order(last_name: :asc, first_name: :asc)
  end
end
```

#### Show

Up next is the show action. For this one we'll define a helper method to handle
raising the correct errors. We have to do this because calling `.run!` would
raise an `ActiveInteraction::InvalidInteractionError` instead of an
`ActiveRecord::RecordNotFound`. That means Rails would render a 500 instead of
a 404.

``` rb
# GET /accounts/:id
def show
  @account = find_account!
end

private

def find_account!
  outcome = FindAccount.run(params)

  if outcome.valid?
    outcome.result
  else
    fail ActiveRecord::RecordNotFound, outcome.errors.full_messages.to_sentence
  end
end
```

This probably looks a little different than you're used to. Rails commonly
handles this with a `before_filter` that sets the `@account` instance variable.
Why is all this interaction code better? Two reasons: One, you can reuse the
`FindAccount` interaction in other places, like your API controller or a Resque
task. And two, if you want to change how accounts are found, you only have to
change one place.

Inside the interaction, we could use `#find` instead of `#find_by_id`. That way
we wouldn't need the `#find_account!` helper method in the controller because
the error would bubble all the way up. However, you should try to avoid raising
errors from interactions. If you do, you'll have to deal with raised exceptions
as well as the validity of the outcome.

``` rb
class FindAccount < ActiveInteraction::Base
  integer :id

  def execute
    account = Account.not_deleted.find_by_id(id)

    if account
      account
    else
      errors.add(:id, 'does not exist')
    end
  end
end
```

Note that it's perfectly fine to add errors during execution. Not all errors
have to come from type checking or validation.

#### New

The new action will be a little different than the ones we've looked at so far.
Instead of calling `.run` or `.run!`, it's going to initialize a new
interaction. This is possible because interactions behave like ActiveModels.

``` rb
# GET /accounts/new
def new
  @account = CreateAccount.new
end
```

Since interactions behave like ActiveModels, we can use ActiveModel validations
with them. We'll use validations here to make sure that the first and last
names are not blank. [The validations section](#validations) goes into more
detail about this.

``` rb
class CreateAccount < ActiveInteraction::Base
  string :first_name, :last_name

  validates :first_name, :last_name,
    presence: true

  def to_model
    Account.new
  end

  def execute
    account = Account.new(inputs)

    unless account.save
      errors.merge!(account.errors)
    end

    account
  end
end
```

We used a couple of advanced features here. The `#to_model` method helps
determine the correct form to use in the view. Check out [the section on
forms](#forms) for more about that. Inside `#execute`, we merge errors. This is
a convenient way to move errors from one object to another. Read more about it
in [the errors section](#errors).

#### Create

The create action has a lot in common with the new action. Both of them use the
`CreateAccount` interaction. And if creating the account fails, this action
falls back to rendering the new action.

``` rb
# POST /accounts
def create
  outcome = CreateAccount.run(params.fetch(:account, {}))

  if outcome.valid?
    redirect_to(outcome.result)
  else
    @account = outcome
    render(:new)
  end
end
```

Note that we have to pass a hash to `.run`. Passing `nil` is an error.

Since we're using an interaction, we don't need strong parameters. The
interaction will ignore any inputs that weren't defined by filters. So you can
forget about `params.require` and `params.permit` because interactions handle
that for you.

#### Destroy

The destroy action will reuse the `#find_account!` helper method we wrote
earlier.

``` rb
# DELETE /accounts/:id
def destroy
  DestroyAccount.run!(account: find_account!)
  redirect_to(accounts_url)
end
```

In this simple example, the destroy interaction doesn't do much. It's not clear
that you gain anything by putting it in an interaction. But in the future, when
you need to do more than `account.destroy`, you'll only have to update one
spot.

``` rb
class DestroyAccount < ActiveInteraction::Base
  object :account

  def execute
    account.destroy
  end
end
```

#### Edit

Just like the destroy action, editing uses the `#find_account!` helper. Then it
creates a new interaction instance to use as a form object.

``` rb
# GET /accounts/:id/edit
def edit
  account = find_account!
  @account = UpdateAccount.new(
    account: account,
    first_name: account.first_name,
    last_name: account.last_name)
end
```

The interaction that updates accounts is more complicated than the others. It
requires an account to update, but the other inputs are optional. If they're
missing, it'll ignore those attributes. If they're present, it'll update them.

ActiveInteraction generates predicate methods (like `#first_name?`) for your
inputs. They will return `false` if the input is `nil` and `true` otherwise.
Skip to [the predicates section](#predicates) for more information about them.

``` rb
class UpdateAccount < ActiveInteraction::Base
  object :account

  string :first_name, :last_name,
    default: nil

  validates :first_name,
    presence: true,
    if: :first_name?
  validates :last_name,
    presence: true,
    if: :last_name?

  def execute
    account.first_name = first_name if first_name?
    account.last_name = last_name if last_name?

    unless account.save
      errors.merge!(account.errors)
    end

    account
  end
end
```

#### Update

Hopefully you've gotten the hang of this by now. We'll use `#find_account!` to
get the account. Then we'll build up the inputs for `UpdateAccount`. Then we'll
run the interaction and either redirect to the updated account or back to the
edit page.

``` rb
# PUT /accounts/:id
def update
  inputs = { account: find_account! }.reverse_merge(params[:account])
  outcome = UpdateAccount.run(inputs)

  if outcome.valid?
    redirect_to(outcome.result)
  else
    @account = outcome
    render(:edit)
  end
end
```

## Advanced usage

### Callbacks

ActiveModel provides a powerful framework for defining callbacks.
ActiveInteraction hooks into that framework to allow hooking into various parts
of an interaction's lifecycle.

``` rb
class Increment < ActiveInteraction::Base
  set_callback :type_check, :before, -> { puts 'before type check' }

  integer :x

  set_callback :validate, :after, -> { puts 'after validate' }

  validates :x,
    numericality: { greater_than_or_equal_to: 0 }

  set_callback :execute, :around, lambda { |_interaction, block|
    puts '>>>'
    block.call
    puts '<<<'
  }

  def execute
    puts 'executing'
    x + 1
  end
end

Increment.run!(x: 1)
# before type check
# after validate
# >>>
# executing
# <<<
# => 2
```

In order, the available callbacks are `type_check`, `validate`, and `execute`.
You can set `before`, `after`, or `around` on any of them.

### Composition

You can run interactions from within other interactions with `#compose`. If the
interaction is successful, it'll return the result (just like if you had called
it with `.run!`). If something went wrong, execution will halt immediately and
the errors will be moved onto the caller.

``` rb
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

To bring in filters from another interaction, use `.import_filters`. Combined
with `inputs`, delegating to another interaction is a piece of cake.

``` rb
class AddAndDouble < ActiveInteraction::Base
  import_filters Add

  def execute
    compose(Add, inputs) * 2
  end
end
```

Note that errors in composed interactions have a few tricky cases. See [the
errors section][] for more information about them.

### Defaults

The default value for an input can take on many different forms. Setting the
default to `nil` makes the input optional. Setting it to some value makes that
the default value for that input. Setting it to a lambda will lazily set the
default value for that input. That means the value will be computed when the
interaction is run, as opposed to when it is defined.

Lambda defaults are evaluated in the context of the interaction, so you can use
the values of other inputs in them.

``` rb
# This input is optional.
time :a, default: nil
# This input defaults to `Time.at(123)`.
time :b, default: Time.at(123)
# This input lazily defaults to `Time.now`.
time :c, default: -> { Time.now }
# This input defaults to the value of `c` plus 10 seconds.
time :d, default: -> { c + 10 }
```

### Descriptions

Use the `desc` option to provide human-readable descriptions of filters. You
should prefer these to comments because they can be used to generate
documentation. The interaction class has a `.filters` method that returns a
hash of filters. Each filter has a `#desc` method that returns the description.

``` rb
class Descriptive < ActiveInteraction::Base
  string :first_name,
    desc: 'your first name'
  string :last_name,
    desc: 'your last name'
end

Descriptive.filters.each do |name, filter|
  puts "#{name}: #{filter.desc}"
end
# first_name: your first name
# last_name: your last name
```

### Errors

ActiveInteraction provides detailed errors for easier introspection and testing
of errors. Detailed errors improve on regular errors by adding a symbol that
represents the type of error that has occurred. Let's look at an example where
an item is purchased using a credit card.

``` rb
class BuyItem < ActiveInteraction::Base
  object :credit_card, :item
  hash :options do
    boolean :gift_wrapped
  end

  def execute
    order = credit_card.purchase(item)
    notify(credit_card.account)
    order
  end

  private def notify(account)
    # ...
  end
end
```

Having missing or invalid inputs causes the interaction to fail and return
errors.

``` rb
outcome = BuyItem.run(item: 'Thing', options: { gift_wrapped: 'yes' })
outcome.errors.messages
# => {:credit_card=>["is required"], :item=>["is not a valid object"], :options=>["has an invalid nested value (\"gift_wrapped\" => \"yes\")"]}
```

Determining the type of error based on the string is difficult if not
impossible. Calling `#details` instead of `#messages` on `errors` gives you
the same list of errors with a testable label representing the error.

``` rb
outcome.errors.details
# => {:credit_card=>[{:error=>:missing}], :item=>[{:type=>"object", :error=>:invalid_type}], :options=>[{:name=>"\"gift_wrapped\"", :value=>"\"yes\"", :error=>:invalid_nested}]}
```

Detailed errors can also be manually added during the execute call by passing a
symbol to `#add` instead of a string.

``` rb
def execute
  errors.add(:monster, :no_passage)
end
```

These types of errors will become standard with Rails 5. ActiveInteraction's
implementation is based off of [active_model-errors_details][].

ActiveInteraction also supports merging errors. This is useful if you want to
delegate validation to some other object. For example, if you have an
interaction that updates a record, you might want that record to validate
itself. By using the `#merge!` helper on `errors`, you can do exactly that.

``` rb
class UpdateThing < ActiveInteraction::Base
  object :thing

  def execute
    unless thing.save
      errors.merge!(thing.errors)
    end

    thing
  end
end
```

When a composed interaction fails, its errors are merged onto the caller. This
generally produces good error messages, but there are a few cases to look out
for.

``` rb
class Inner < ActiveInteraction::Base
  boolean :x, :y
end

class Outer < ActiveInteraction::Base
  string :x
  boolean :z, default: nil

  def execute
    compose(Inner, x: x, y: z)
  end
end

outcome = Outer.run(x: 'yes')
outcome.errors.details
# => { :x    => [{ :error => :invalid_type, :type => "boolean" }],
#      :base => [{ :error => "Y is required" }] }
outcome.errors.full_messages.join(' and ')
# => "X is not a valid boolean and Y is required"
```

Since both interactions have an input called `x`, the inner error for that
input is moved to the `x` error on the outer interaction. This results in a
misleading error that claims the input `x` is not a valid boolean even though
it's a string on the outer interaction.

Since only the inner interaction has an input called `y`, the inner error for
that input is moved to the `base` error on the outer interaction. This results
in a confusing error that claims the input `y` is required even though it's not
present on the outer interaction.

### Forms

The outcome returned by `.run` can be used in forms as though it were an
ActiveModel object. You can also create a form object by calling `.new` on the
interaction.

Given an application with an `Account` model we'll create a new `Account` using
the `CreateAccount` interaction.

```rb
# GET /accounts/new
def new
  @account = CreateAccount.new
end

# POST /accounts
def create
  outcome = CreateAccount.run(params.fetch(:account, {}))

  if outcome.valid?
    redirect_to(outcome.result)
  else
    @account = outcome
    render(:new)
  end
end
```

The form used to create a new `Account` has slightly more information on the
`form_for` call than you might expect.

```erb
<%= form_for @account, as: :account, url: accounts_path do |f| %>
  <%= f.text_field :first_name %>
  <%= f.text_field :last_name %>
  <%= f.submit 'Create' %>
<% end %>
```

This is necessary because we want the form to act like it is creating a new
`Account`. Defining `to_model` on the `CreateAccount` interaction tells the
form to treat our interaction like an `Account`.

```rb
class CreateAccount < ActiveInteraction::Base
  # ...

  def to_model
    Account.new
  end
end
```

Now our `form_for` call knows how to generate the correct URL and param name
(i.e. `params[:account]`).

```erb
# app/views/accounts/new.html.erb
<%= form_for @account do |f| %>
  <%# ... %>
<% end %>
```

If you have an interaction that updates an `Account`, you can define `to_model`
to return the object you're updating.

```rb
class UpdateAccount < ActiveInteraction::Base
  # ...

  object :account

  def to_model
    account
  end
end
```

ActiveInteraction also supports [formtastic][] and [simple_form][]. The filters
used to define the inputs on your interaction will relay type information to
these gems. As a result, form fields will automatically use the appropriate
input type.

### Grouped inputs

It can be convenient to apply the same options to a bunch of inputs. One common
use case is making many inputs optional. Instead of setting `default: nil` on
each one of them, you can use [`with_options`][] to reduce duplication.

``` rb
with_options default: nil do
  date :birthday
  string :name
  boolean :wants_cake
end
```

### Optional inputs

Optional inputs can be defined by using the `:default` option as described in
[the filters section][]. Within the interaction, provided and default values
are merged to create `inputs`. There are times where it is useful to know
whether a value was passed to `run` or the result of a filter default. In
particular, it is useful when `nil` is an acceptable value. For example, you
may optionally track your users' birthdays. You can use the `given?` predicate
to see if an input was even passed to `run`. With `given?` you can also check
the input of a hash filter by passing a series of keys to check.

``` rb
class UpdateUser < ActiveInteraction::Base
  object :user
  date :birthday,
    default: nil

  def execute
    user.birthday = birthday if given?(:birthday)
    errors.merge!(user.errors) unless user.save
    user
  end
end
```

Now you have a few options. If you don't want to update their birthday, leave
it out of the hash. If you want to remove their birthday, set `birthday: nil`.
And if you want to update it, pass in the new value as usual.

``` rb
user = User.find(...)

# Don't update their birthday.
UpdateUser.run!(user: user)

# Remove their birthday.
UpdateUser.run!(user: user, birthday: nil)

# Update their birthday.
UpdateUser.run!(user: user, birthday: Date.new(2000, 1, 2))
```

### Predicates

ActiveInteraction creates a predicate method for every input defined by a
filter. So if you have an input called `foo`, there will be a predicate method
called `#foo?`. That method will tell you if the input was given (that is, if
it was not `nil`).

``` rb
class SayHello < ActiveInteraction::Base
  string :name,
    default: nil

  def execute
    if name?
      "Hello, #{name}!"
    else
      "Howdy, stranger!"
    end
  end
end

SayHello.run!(name: nil)
# => "Howdy, stranger!"
SayHello.run!(name: 'Taylor')
# => "Hello, Taylor!"
```

This can be confusing for boolean inputs. If you have some boolean input `foo`,
then the actual value of that input is available through `foo`. The associated
predicate method, `#foo?`, will tell you if that value is not `nil`. So it will
only be `false` if the input is optional and happens to be `nil`.

See [the optional inputs section][] for help on determining if an input was
present in the input hash instead of just `nil`.

### Translations

ActiveInteraction is i18n aware out of the box! All you have to do is add
translations to your project. In Rails, these typically go into
`config/locales`. For example, let's say that for some reason you want to print
everything out backwards. Simply add translations for ActiveInteraction to your
`hsilgne` locale.

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
      object: tcejbo
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

## Credits

ActiveInteraction is brought to you by [Aaron Lasseigne][] and
[Taylor Fausak][] and was originally built at [OrgSync][].

If you want to contribute to ActiveInteraction, please read
[our contribution guidelines][]. A [complete list of contributors][] is
available on GitHub.

ActiveInteraction is licensed under [the MIT License][].

[activeinteraction]: https://github.com/AaronLasseigne/active_interaction
[Full Documentation]: http://rubydoc.info/github/orgsync/active_interaction
[semantic versioning]: http://semver.org/spec/v2.0.0.html
[GitHub releases]: https://github.com/AaronLasseigne/active_interaction/releases
[the announcement post]: http://devblog.orgsync.com/2015/05/06/announcing-active-interaction-2/
[active_model-errors_details]: https://github.com/cowbell/active_model-errors_details
[aaron lasseigne]: https://github.com/AaronLasseigne
[taylor fausak]: https://github.com/tfausak
[orgsync]: https://github.com/orgsync
[our contribution guidelines]: CONTRIBUTING.md
[complete list of contributors]: https://github.com/AaronLasseigne/active_interaction/graphs/contributors
[the mit license]: LICENSE.md
[formtastic]: https://rubygems.org/gems/formtastic
[simple_form]: https://rubygems.org/gems/simple_form
[the filters section]: #filters
[the errors section]: #errors
[the optional inputs section]: #optional-inputs
[aire]: example
[`with_options`]: http://api.rubyonrails.org/classes/Object.html#method-i-with_options
