begin
  require 'active_record'
rescue LoadError
end

module ActiveInteraction
  # Compose interactions by piping them together.
  class Pipeline
    # Set up a pipeline with a series of interactions.
    #
    # @example
    #   ActiveInteraction::Pipeline.new do
    #     pipe InteractionOne
    #     pipe InteractionTwo
    #   end
    def initialize(&block)
      @steps = []
      instance_eval(&block) if block_given?
    end

    # Add an interaction to the end of the pipeline.
    #
    # @example With a lambda
    #   pipe Interaction, -> result { { a: result, b: result } }
    #
    # @example With a symbol
    #   pipe Interaction, :thing
    #   # -> result { { thing: result } }
    #
    # @example With nil
    #   pipe Interaction
    #   # -> result { result }
    #
    # @param [Base] interaction The interaction to add.
    # @param [Proc, Symbol, nil] function A function to convert the result of
    #   the last interaction into the input for this interaction. To pass the
    #   result straight through, use `nil`. To pass the result as a value in a
    #   hash, pass the key as a symbol.
    #
    # @return [nil]
    def pipe(interaction, function = nil)
      @steps << [lambdafy(function), interaction]
      nil
    end

    # Run all the interactions in the pipeline. If any interaction fails, stop
    #   and return immediately without running any more interactions.
    #
    # @param (see Base.run)
    #
    # @return [Base] An instance of the class of the last interaction in the
    #   pipeline. If any interaction fails, an instance of that class will be
    #   returned instead.
    #
    # @raise [EmptyPipeline] If nothing is in the pipeline. Add things with
    #   {#pipe}.
    def run(*args)
      raise EmptyPipeline if @steps.empty?
      transaction do
        (function, interaction), *steps = @steps
        outcome = interaction.run(function.call(*args))
        steps.reduce(outcome) { |o, (f, i)| bind(o, f, i) }
      end
    end

    # Run all the interactions in the pipeline. If any interaction fails, stop
    #   and raise immediately without running any more interactions.
    #
    # @param (see #run)
    #
    # @return (see Base.run!)
    #
    # @raise (see #run)
    # @raise (see Base.run!)
    def run!(*args)
      outcome = run(*args)
      if outcome.invalid?
        raise InteractionInvalid, outcome.errors.full_messages.join(', ')
      end
      outcome.result
    end

    private

    def bind(outcome, function, interaction)
      if outcome.valid?
        interaction.run(function.call(outcome.result))
      else
        outcome
      end
    end

    def lambdafy(thing)
      case thing
      when NilClass
        -> result { result }
      when Symbol
        -> result { { thing => result } }
      else
        thing
      end
    end

    def transaction
      return unless block_given?

      if defined?(ActiveRecord)
        ::ActiveRecord::Base.transaction { yield }
      else
        yield
      end
    end
  end
end
