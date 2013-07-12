# ActiveInteraction

[![Gem Version][]](https://badge.fury.io/rb/active_interaction)
[![Build Status][]](https://travis-ci.org/orgsync/active_interaction)
[![Coverage Status][]](https://coveralls.io/r/orgsync/active_interaction)
[![Code Climate][]](https://codeclimate.com/github/orgsync/active_interaction)
[![Dependency Status][]](https://gemnasium.com/orgsync/active_interaction)

At first it seemed alright. A little business logic in a controller or model
wasn't going to hurt anything. Then one day you wake up and you're surrounded
by fat models and unweildy controller methods. Curled up and crying in the
corner you can help but wonder how it came to this. Take back control. Slim
down models and wrangle monstrous controller methods with ActiveInteraction.

## Installation

This project uses [semantic versioning][].

Add it to your Gemfile:

    gem 'active_interaction', '~> 0.1.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_interaction

## What do I get?

ActiveInteraction::Base lets you create interaction models. These models ensure
that certain options are provided and that these options are in the format you
want them in. If the options are valid it calls an `execute` method, stores the
result of that method in `result`, and returns an instance of your
ActiveInteraction::Base subclass. Let's looks at a simple example:

    # Define an interaction that signs up a user.
    class UserSignup < ActiveInteraction::Base
      # required
      string :email, :name

      # optional
      boolean :newsletter_subscribe, allow_nil: true

      # ActiveRecord validations
      validates :email, format: EMAIL_REGEX

      # The execute method is called only if the options validate. It does your
      # business action. The return value will be stored in `result`.
      def execute
        user = User.create!(email: email, name: name)
        NewsletterSubscriptions.create(email: email, user_id: user.id) if newsletter_subscribe
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

You might have noticed that ActiveInteraction::Base quacks like ActiveRecord::Base.
It can use validations from your Rails application and check validation with
`valid?`. Any errors are added to `errors` which works exactly like an ActiveRecord
model.

## How do I call an interaction?

There are two way to call an interaction. Given UserSignup, you can do this:

    outcome = UserSignup.run(params)
    if outcome.valid?
      p outcome.result
    else
      p outcome.errors
    end

Or, you can do this:

    result = UserSignup.run!(params) # returns the result of execute, or raises ActiveInteraction::InteractionInvalid

## What can I pass to an interaction?

ActiveInteractions only accept a Hash for `run` and `run!`.

    # A user comments on an article
    class CreateComment < ActiveInteraction::Base
      model :article, :user
      string :comment

      validates :comment, length: {maximum: 500}

      def execute; ...; end
    end

    def somewhere
      outcome = CreateComment.run(
        comment: params[:comment],
        article: Article.find(params[:article_id]),
        user: current_user
      )
    end

## How do I define an interaction?

1. Subclass ActiveInteraction::Base

        class YourInteraction < ActiveInteraction::Base
          # ...
        end

2. Define your attributes:

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
        time :arrives_at, :departs_at

3. Use any additional validations you need:

        validates :name, length: {maximum: 10}
        validates :state, inclusion: {in: %w(AL AK AR ... WY)}
        validate arrives_before_departs

        private

        def arrive_before_departs
          if departs_at <= arrives_at
            errors.add(:departs_at, 'must come after the arrival time')
          end
        end

4. Define your execute method. It can return whatever you like:

        def execute
          record = do_thing(...)
          # ...
          record
        end

See a full list of methods can be found [here](http://www.rubydoc.info/github/orgsync/active_interaction/master/ActiveInteraction/Base).

## Credits

This project was inspired by the fantastic work done in [Mutations][].

[build status]: https://travis-ci.org/orgsync/active_interaction.png
[code climate]: https://codeclimate.com/github/orgsync/active_interaction.png
[coverage status]: https://coveralls.io/repos/orgsync/active_interaction/badge.png
[dependency status]: https://gemnasium.com/orgsync/active_interaction.png
[gem version]: https://badge.fury.io/rb/active_interaction.png
[mutations]: https://github.com/cypriss/mutations
[semantic versioning]: http://semver.org
