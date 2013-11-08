require 'spec_helper'

describe ActiveInteraction::Pipeline do
  it 'succeeds' do
    HashInteraction = Class.new(ActiveInteraction::Base) do
      integer :a
      def execute; { a: a, b: a } end
    end
    AddInteraction = Class.new(ActiveInteraction::Base) do
      integer :a, :b
      def execute; a + b end
    end
    SquareInteraction = Class.new(ActiveInteraction::Base) do
      integer :a
      def execute; a ** 2 end
    end
    MultiplyInteraction = Class.new(ActiveInteraction::Base) do
      integer :a, :b
      def execute; a * b end
    end

    pipeline = ActiveInteraction::Pipeline.new do
      pipe HashInteraction
      pipe AddInteraction
      pipe SquareInteraction, :a
      pipe MultiplyInteraction, ->(result) { { a: result, b: 3 } }
    end
    outcome = pipeline.run(a: 5)
    expect(outcome.result).to eq(((5 + 5) ** 2) * 3)
  end
end
