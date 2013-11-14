begin
  require 'active_record'
rescue LoadError
end

module ActiveInteraction
  # Compose interactions by piping them together.
  #
  # @since 0.7.0
  class Pipeline
    include Core

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
    # @param interaction [Base] the interaction to add
    # @param function [Proc] a function to convert the output of an interaction
    #   into the input for the next one
    # @param function [Symbol] a shortcut for creating a function that puts the
    #   output into a hash with this key
    # @param function [nil] a shortcut for creating a function that passes the
    #   output straight through
    #
    # @return [Pipeline]
    def pipe(interaction, function = nil)
      @steps << [lambdafy(function), interaction]
      self
    end

    # Run all the interactions in the pipeline. If any interaction fails, stop
    #   and return immediately without running any more interactions.
    #
    # @param (see Base.run)
    #
    # @return [Base] an instance of the last successful interaction in the
    #   pipeline
    #
    # @raise [EmptyPipelineError] if nothing is in the pipeline
    def run(*args)
      raise EmptyPipelineError if @steps.empty?
      transaction do
        function, interaction = @steps.first
        outcome = interaction.run(function.call(*args))
        @steps[1..-1].reduce(outcome) { |o, (f, i)| bind(o, f, i) }
      end
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
  end
end
