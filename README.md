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
    - [Index](#index)
    - [Show](#show)
    - [New](#new)
    - [Create](#create)
    - [Destroy](#destroy)
    - [Edit](#edit)
    - [Update](#update)
  - [Structure](#structure)
- [Filters](#filters)
  - [Array](#array)
  - [Boolean](#boolean)
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
    - [Decimal](#decimal)
    - [Float](#float)
    - [Integer](#integer)
- [Advanced usage](#advanced-usage)
  - [Callbacks](#callbacks)
  - [Composition](#composition)
  - [Errors](#errors)
  - [Forms](#forms)
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

To define an interaction, create a subclass of `ActiveInteraction::Base`. Then
you need to do two things:

1.  Define your inputs. Use class methods to define what you expect your
    parameters to look like. For instance, if you need a boolean flag for
    pepperoni, use `boolean :wants_pepperoni`. Check out [the filters
    section](#filters) for all the available options.

2.  Define your business logic. Do this by implementing the `#execute` method.
    Each input you defined will be available as the type you specified. If any
    of the inputs are invalid, `#execute` won't be run. Check out [the
    validations section](#validations) if you need more than type checking.

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
valid. If it's invalid, take a look at its errors with `#errors`. If it's
valid, you can get the result through `#result`.

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

You can also use `.run!` to execute interactions. It's like `.run` but more
dangerous. It doesn't return an outcome. If the outcome would be invalid, it
will instead raise an error. But if the outcome would be valid, it simply
returns the result.

``` rb
Square.run!(x: 'two point three')
# ActiveInteraction::InvalidInteractionError: X is not a valid float

Square.run!(x: 2.3)
# => 5.289999999999999
```

### Rails

ActiveInteraction is designed to work well with Rails. Use interactions to
handle your business logic instead of models or controllers. Let's take a look
at a complete example of a controller with the typical resourceful actions.

ActiveInteraction plays nicely with Rails. You can use interactions to handle
your business logic instead of models or controllers. To see how it all works,
let's take a look at a complete example of a controller with the typical
resourceful actions.

#### Index

The index action is as good a place as any to start.

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

Inside the interaction, we could use `#find` instead of `#find_by_id`. That way
we wouldn't need the `#find_account!` helper method in the controller because
the error would bubble all the way up. However you should try to avoid raising
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

    if account.save
      account
    else
      errors.merge(account.errors)
    end
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

#### Destroy

The destroy action will reuse the `#find_account!` helper method we wrote
earlier.

``` rb
# DELETE /accounts/:id
def destroy
  account = find_account!
  DestroyAccount.run!(account: account)
  redirect_to(accounts_url)
end
```

In this simple example, the destroy interaction doesn't do much. It's not clear
that you gain anything by putting it in an interaction. But in the future, when
you need to do more than `account.destroy`, you'll only have to update one
spot.

``` rb
class DestroyAccount < ActiveInteraction::Base
  model :account

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

``` rb
class UpdateAccount < ActiveInteraction::Base
  model :account

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

    if account.save
      account
    else
      errors.merge(account.errors)
    end
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
  account = find_account!
  inputs = { account: account }.reverse_merge(params[:account])
  outcome = UpdateAccount.run(inputs)

  if outcome.valid?
    redirect_to(outcome.result)
  else
    @account = outcome
    render(:edit)
  end
end
```

### Structure

We recommend putting your interactions in `app/interactions`. It's also very
helpful to group them by model. That way you can look in
`app/interactions/accounts` for all the ways you can interact with accounts.

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

## Filters

You can define filters inside an interaction using the appropriate class method.
Each method has the same signature:

- Some symbolic names. These are the attributes to create.

- An optional hash of options. Each filter supports at least these two options:

  - `default` is the fallback value to use if `nil` is give. To make a filter
    optional, set `default: nil`.

  - `desc` is a human-readable description of the input. This can be useful for
    generating documentation.

- An optional block of sub-filters. Only [array](#array) and [hash](#hash)
  filters support this. Other filters will ignore blocks when given to them.

Let's take a look at an example filter. It defines three inputs: `x`, `y`, and
`z`. Those inputs are optional and they all share the same description ("an
example filter").

``` rb
filter :x, :y, :z,
  default: nil,
  desc: 'an example filter' do
    # Some filters support sub-filters here.
  end
```

In general, filters accept values of the type the correspond to, plus a few
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

Note that filters inside an array block don't have names. Also you can only
have one filter inside an array block.

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

File filters also accept tempfiles and anything that responds to `#tempfile`.
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

Hash filters accept hashes. They require keys to be either strings or symbols.
The expected value types are given by passing a block and nesting other
filters. You can have any number of filters inside a hash, including other
hashes.

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

InterfaceInteraction.run!(serializer: Object.new)
# ActiveInteraction::InvalidInteractionError: Serializer is not a valid interface

require 'json'
InterfaceInteraction.run!(serializer: JSON)
# => "{\"is_json\":true}"
```

### Model

Model filters allow you to require an instance of a particular class. It checks
either `#is_a?` on the instance or `.===` on the class.

``` rb
class Cow
  def moo
    'Moo!'
  end
end

class ModelInteraction < ActiveInteraction::Base
  model :cow

  def execute
    cow.moo
  end
end

ModelInteraction.run!(cow: Object.new)
# ActiveInteraction::InvalidInteractionError: Cow is not a valid model
ModelInteraction.run!(cow: Cow.new)
# => "Moo!"
```

The class name is automatically determined by the filter name. If your filter
name is different than your class name, use the `class` option. It can be
either the class, a string, or a symbol.

``` rb
model :dolly1,
  class: Sheep
model :dolly2,
  class: 'Sheep'
model :dolly3,
  class: :Sheep
```

### String

TODO

### Symbol

TODO

### Dates and times

TODO

#### Date

TODO

#### Date and time

TODO

#### Time

TODO

### Numbers

TODO

#### Decimal

TODO

#### Float

TODO

#### Integer

TODO

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

  set_callback :execute, :around, lambda { |_, block|
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

### Errors

ActiveInteraction provides symbolic errors for easier introspection and testing
of errors. Symbolic errors improve on regular errors by adding a symbol that
represents the type of error that has occurred. Let's look at an example where
an item is purchased using a credit card.

``` rb
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

``` rb
outcome = BuyItem.run(item: 'Thing', options: { gift_wrapped: 'yes' })
outcome.errors.messages
# => {:credit_card=>["is required"], :item=>["is not a valid model"], :options=>["has an invalid nested value (\"gift_wrapped\" => \"yes\")"]}
```

Determining the type of error based on the string is difficult if not
impossible. Calling `#symbolic` instead of `#messages` on `errors` gives you
the same list of errors with a testable label representing the error.

``` rb
outcome.errors.symbolic
# => {"credit_card"=>[:missing], "item"=>[:invalid_type], "options"=>[:invalid_nested]}
```

Symbolic errors can also be manually added during the execute call by calling
`#add_sym` instead of `#add` on `errors`. It works the same way as `add` except
that the second argument is the error label.

``` rb
def execute
  errors.add_sym(:monster, :no_passage, 'You shall not pass!')
end
```

ActiveInteraction also supports merging errors. This is useful if you want to
delegate validation to some other object. For example, if you have an
interaction that updates a record, you might want that record to validate
itself. By using the `#merge!` helper on `errors`, you can do exactly that.

``` rb
class UpdateThing < ActiveInteraction::Base
  model :thing

  def execute
    if thing.save
      thing
    else
      errors.merge!(thing.errors)
    end
  end
end
```

### Forms

TODO

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

### Validation

ActiveInteraction type checks your inputs. Often you'll want more than that.
For instance, you may want an input to be a string with at least one
non-whitespace character. Instead of writing your own validation for that, you
can use validations from ActiveModel.

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

When you run this interaction, two things will happen. First ActiveInteraction
will type check your inputs. Then ActiveModel will validate them. If both of
those are happy, it will be executed.

``` rb
SayHello.run!(name: nil)
# ActiveInteraction::InvalidInteractionError: Name is required

SayHello.run!(name: '')
# ActiveInteraction::InvalidInteractionError: Name can't be blank

SayHello.run!(name: 'Taylor')
# => "Hello, Taylor!"
```

## Credits

ActiveInteraction is brought to you by [Aaron Lasseigne][] and
[Taylor Fausak][] from [OrgSync][]. We were inspired by the fantastic work done
by [Jonathan Novak][] on [Mutations][].

If you want to contribute to ActiveInteraction, please read
[our contribution guidelines][]. A [complete list of contributors][] is
available on GitHub.

ActiveInteraction is licensed under [the MIT License][].

[the project page]: http://orgsync.github.io/active_interaction/
[the full documentation]: http://rubydoc.info/github/orgsync/active_interaction
[semantic versioning]: http://semver.org/spec/v2.0.0.html
[the change log]: CHANGELOG.md
[aaron lasseigne]: https://github.com/AaronLasseigne
[taylor fausak]: https://github.com/tfausak
[orgsync]: https://github.com/orgsync
[jonathan novak]: https://github.com/cypriss
[mutations]: https://github.com/cypriss/mutations
[our contribution guidelines]: CONTRIBUTING.md
[complete list of contributors]: https://github.com/orgsync/active_interaction/graphs/contributors
[the mit license]: LICENSE.txt
