module ActiveInteraction
  class Pipeline
    def initialize(&block)
      @steps = []
      instance_eval(&block)
    end

    def pipe(interaction, function = nil)
      @steps << [lambdafy(function), interaction]
    end

    def run(options = {})
      raise EmptyPipeline if @steps.empty?
      (function, interaction), *steps = @steps
      outcome = interaction.run(function.call(options))
      steps.reduce(outcome) { |o, (f, i)| bind(o, f, i) }
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
      when Proc
        thing
      when NilClass
        -> result { result }
      when Symbol
        -> result { { thing => result } }
      else
        raise
      end
    end
  end
end
