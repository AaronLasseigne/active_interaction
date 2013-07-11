# ActiveInteraction

[![Gem Version][]](https://badge.fury.io/rb/active_interaction)
[![Build Status][]](https://travis-ci.org/orgsync/active_interaction)
[![Coverage Status][]](https://coveralls.io/r/orgsync/active_interaction)
[![Code Climate][]](https://codeclimate.com/github/orgsync/active_interaction)
[![Dependency Status][]](https://gemnasium.com/orgsync/active_interaction)

Manage application specific business logic.

This project uses [semantic versioning][].

## Installation

Add it to your Gemfile:

    gem 'active_interaction', '~> 0.1.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_interaction

## Example

    # Define an interaction that signs up a user.
    class UserSignup < ActiveInteraction::Base
      # required
      string :email, :name

      # optional
      boolean :newsletter_subscribe, allow_nil: true
      
      # ActiveRecord validations
      validates :email, format: EMAIL_REGEX

      # The execute method is called only if the attributes validate. It does your business action.
      def execute
        user = User.create!(email: email, name: name)
        NewsletterSubscriptions.create(email: email, user_id: user.id) if newsletter_subscribe
        UserMailer.async(:deliver_welcome, user.id)
        user
      end
    end

    # In a controller action (for instance), you can run it:
    def create
      outcome = UserSignup.run(params[:user])

      # Then check to see if it worked:
      if outcome.valid?
        render json: {message: "Great success, #{outcome.result.name}!"}
      else
        render json: outcome.errors.full_messages.to_json, status: 422
      end
    end
    
## How do I call an ActiveInteraction?

You have two choices. Given UserSignup, you can do this:

    outcome = UserSignup.run(params)
    if outcome.valid?
      p outcome.result
    else
      p outcome.errors
    end

Or, you can do this:

    outcome = UserSignup.run!(params) # returns the outcome, or raises ActiveInteraction::InteractionInvalid
    
## What can I pass to interactions?

ActiveInteractions only accepts a Hash for `run` and `run!`.

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
    
## How do I define interactions?

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

3. Use any additional validations you like:

        validates :name, length: {maximum: 10} 
        validates :state, inclusion: {in: %w(AL AK AR ... WY)}

4. Define your execute method. It can return a value:

        def execute
          record = do_thing(...)
          # ...
          record
        end


See a full list of options [here](http://www.rubydoc.info/github/orgsync/active_interaction/master/ActiveInteraction/Base).


## Credits

This project was inspired by the fantastic work done in [Mutations][].

[build status]: https://travis-ci.org/orgsync/active_interaction.png
[code climate]: https://codeclimate.com/github/orgsync/active_interaction.png
[coverage status]: https://coveralls.io/repos/orgsync/active_interaction/badge.png
[dependency status]: https://gemnasium.com/orgsync/active_interaction.png
[gem version]: https://badge.fury.io/rb/active_interaction.png
[mutations]: https://github.com/cypriss/mutations
[semantic versioning]: http://semver.org
