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

    def pipe(interaction, function = nil)
      if function.nil?
        function = -> result { result }
      elsif function.is_a?(Symbol)
        symbol = function
        function = -> result { { symbol => result } }
      end
      @steps << [function, interaction]
    end
  end
end
