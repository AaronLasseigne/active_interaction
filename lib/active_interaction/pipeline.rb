module ActiveInteraction
  class Pipeline
    def initialize(&block)
      @steps = []
      instance_eval(&block)
    end

    def run(options = {})
      raise EmptyPipeline if @steps.empty?
      (function, interaction), *steps = @steps
      outcome = interaction.run(function.call(options))
      steps.reduce(outcome) do |o, (f, i)|
        o.valid? ? i.run(f.call(o.result)) : o
      end
    end

    private

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

    def pipe(interaction, function = nil)
      @steps << [lambdafy(function), interaction]
    end
  end
end
