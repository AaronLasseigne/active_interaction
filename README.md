# ActiveInteraction

[![Gem Version][]][1]
[![Build Status][]][2]
[![Coverage Status][]][3]
[![Code Climate][]][4]
[![Dependency Status][]][5]

At first it seemed alright. A little business logic in a controller
or model wasn't going to hurt anything. Then one day you wake up
and you're surrounded by fat models and unwieldy controllers. Curled
up and crying in the corner, you can't help but wonder how it came
to this.

Take back control. Slim down models and wrangle monstrous controller
methods with ActiveInteraction.

## Installation

This project uses [semantic versioning][].

Add it to your Gemfile:

```ruby
gem 'active_interaction', '~> 0.3.0'
```

And then execute:

```sh
$ bundle
```

Or install it yourself with:

```sh
$ gem install active_interaction
```

## What do I get?

ActiveInteraction::Base lets you create interaction models. These
models ensure that certain options are provided and that those
options are in the format you want them in. If the options are valid
it will call `execute`, store the return value of that method in
`result`, and return an instance of your ActiveInteraction::Base
subclass. Let's looks at a simple example:

```ruby
# Define an interaction that signs up a user.
class UserSignup < ActiveInteraction::Base
  # required
  string :email, :name

  # optional
  boolean :newsletter_subscribe, allow_nil: true

  # ActiveRecord validations
  validates :email, format: EMAIL_REGEX

  # The execute method is called only if the options validate. It
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
`errors` which works exactly like an ActiveRecord model. Additionally,
everything within the `execute` method is run in a transaction if
ActiveRecord is available.

## How do I call an interaction?

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
# or raises ActiveInteraction::InteractionInvalid
```

## What can I pass to an interaction?

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

## How do I define an interaction?

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
    array :tags, allow_nil: true do
      string
    end
    hash :prefs, allow_nil: true do
      boolean :smoking
      boolean :view
    end
    date :arrives_on, default: Date.today
    date :departs_on, default: Date.tomorrow
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

Check out the [documentation][] for a full list of methods.

## How do I translate an interaction?

If you want to translate ActiveInteraction into another language,
drop a YAML file into `lib/active_interaction/locale`. For instance,
let's say (for whatever reason) you want to print out everything
backwards. Just add a `hsilgne.yml` locale:

```yaml
# lib/active_interaction/locale/hsilgne.yml
hsilgne:
  active_interaction:
    types:
      array: yarra
      boolean: naeloob
      date: etad
      date_time: emit etad
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
        invalid_nested: '%{type} dilav a ton si'
        missing: deriuqer si
```

Then set your locale and run an interaction like normal:

```ruby
require 'active_interaction'
I18n.locale = :hsilgne
class Interaction < ActiveInteraction::Base
  boolean :a
  def execute; end
end
p Interaction.run.errors.messages
# => {:a=>["deriuqer si"]}
```

## Credits

This project was inspired by the fantastic work done in [Mutations][].

  [1]: https://badge.fury.io/rb/active_interaction "Gem Version"
  [2]: https://travis-ci.org/orgsync/active_interaction "Build Status"
  [3]: https://coveralls.io/r/orgsync/active_interaction "Coverage Status"
  [4]: https://codeclimate.com/github/orgsync/active_interaction "Code Climate"
  [5]: https://gemnasium.com/orgsync/active_interaction "Dependency Status"
  [build status]: https://travis-ci.org/orgsync/active_interaction.png
  [code climate]: https://codeclimate.com/github/orgsync/active_interaction.png
  [coverage status]: https://coveralls.io/repos/orgsync/active_interaction/badge.png
  [dependency status]: https://gemnasium.com/orgsync/active_interaction.png
  [documentation]: http://rubydoc.info/github/orgsync/active_interaction
  [gem version]: https://badge.fury.io/rb/active_interaction.png
  [mutations]: https://github.com/cypriss/mutations
  [semantic versioning]: http://semver.org
