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

### Errors

### Forms

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
