require 'spec_helper'

describe ActiveInteraction::Sugarable do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  InnerInteraction = Class.new(TestInteraction) do
    integer :x
    integer :y

    def execute
      x + y
    end
  end

  describe '#composable' do
    subject { OuterInteraction.run!(x: 5, y: 20) }

    context 'with default method name for inner interaction' do
      OuterInteraction = Class.new(TestInteraction) do
        integer :x
        integer :y

        composable(InnerInteraction, %i[x y])

        def execute
          inner_interaction
        end
      end

      it { is_expected.to eq(25) }
    end

    context 'with custom method name for inner interaction' do
      OuterInteraction = Class.new(TestInteraction) do
        integer :x
        integer :y

        composable(InnerInteraction, %i[x y], method: 'custom_interaction')

        def execute
          custom_interaction
        end
      end

      it { is_expected.to eq(25) }
    end

    context 'with inner interaction with namespace' do
      module CustomNamespace
        class InnerInteraction < TestInteraction
          integer :x
          integer :y

          def execute
            x + y
          end
        end
      end

      OuterInteraction = Class.new(TestInteraction) do
        integer :x
        integer :y

        composable(CustomNamespace::InnerInteraction, %i[x y])

        def execute
          custom_namespace_inner_interaction
        end
      end

      it { is_expected.to eq(25) }
    end

    context 'with passing data from method' do
      OuterInteraction = Class.new(TestInteraction) do
        integer :x

        composable(InnerInteraction, %i[x y])

        def execute
          inner_interaction
        end

        def y
          20
        end
      end

      it { is_expected.to eq(25) }
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
