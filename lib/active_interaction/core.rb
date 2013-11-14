begin
  require 'active_record'
rescue LoadError
end

module ActiveInteraction
  # Functionality common between {Base} and {Pipeline}.
  #
  # @see Base
  # @see Pipeline
  module Core
    # Like {Base.run} except that it returns the value of {Base#execute} or
    #   raises an exception if there were any validation errors.
    #
    # @param (see Base.run)
    #
    # @return [Object] the return value of {Base#execute}
    #
    # @raise [InteractionInvalidError] if the outcome is invalid
    def run!(*args)
      outcome = run(*args)

      if outcome.valid?
        outcome.result
      else
        raise InteractionInvalidError.new(outcome.errors.full_messages.join(', '))
      end
    end

    private

    def transaction(*args, &block)
      if defined?(ActiveRecord)
        ActiveRecord::Base.transaction(*args, &block)
      else
        yield
      end
    end
  end
end
