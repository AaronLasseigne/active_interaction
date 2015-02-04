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

## Installation

This project uses [semantic versioning][3].

Add it to your Gemfile:

``` ruby
gem 'active_interaction', '~> 1.4'
```

And then execute:

``` sh
$ bundle
```

Or install it yourself with:

``` sh
$ gem install active_interaction
```

## What do I get?

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
`errors` which works exactly like an ActiveRecord model. By default,
everything within the `execute` method is run in a transaction if
ActiveRecord is available.

## How do I call an interaction?

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

## What can I pass to an interaction?

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

## How do I define an interaction?

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

## How do I compose interactions?

You can run interactions from within other interactions by calling `compose`.
If the interaction is successful, it'll return the result (just like if you had
called it with `run!`). If something went wrong, execution will halt
immediately and the errors will be moved onto the caller.

``` ruby
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

## How do I translate an interaction?

ActiveInteraction is i18n-aware out of the box! All you have to do
is add translations to your project. In Rails, they typically go
into `config/locales`. So, for example, let's say that (for whatever
reason) you want to print out everything backwards. Simply add
translations for ActiveInteraction to your `hsilgne` locale:

``` yaml
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
      time: emit
    errors:
      messages:
        invalid: dilavni si
        invalid_type: '%{type} dilav a ton si'
        missing: deriuqer si
```

Then set your locale and run an interaction like normal:

``` ruby
I18n.locale = :hsilgne
class Interaction < ActiveInteraction::Base
  boolean :a
  def execute; end
end
p Interaction.run.errors.messages
# => {:a=>["deriuqer si"]}
```

## Credits

ActiveInteraction is brought to you by [@AaronLasseigne][4] and
[@tfausak][5] from [@orgsync][6]. We were inspired by the fantastic
work done in [Mutations][7].

  [1]: http://orgsync.github.io/active_interaction/
  [2]: http://rubydoc.info/github/orgsync/active_interaction
  [3]: http://semver.org/spec/v2.0.0.html
  [4]: https://github.com/AaronLasseigne
  [5]: https://github.com/tfausak
  [6]: https://github.com/orgsync
  [7]: https://github.com/cypriss/mutations
