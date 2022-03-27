require 'spec_helper'

describe ActiveInteraction::Inputs do
  subject(:inputs) { described_class.new(args, base_class.new) }

  let(:args) { {} }
  let(:base_class) { ActiveInteraction::Base }

  describe '.reserved?(name)' do
    it 'returns true for anything starting with "_interaction_"' do
      expect(described_class).to be_reserved('_interaction_')
    end

    it 'returns true for existing instance methods' do
      (
        (ActiveInteraction::Base.instance_methods - Object.instance_methods) +
        (ActiveInteraction::Base.private_instance_methods - Object.private_instance_methods)
      ).each do |method|
        expect(described_class).to be_reserved(method)
      end
    end

    it 'returns false for anything else' do
      expect(described_class).to_not be_reserved(SecureRandom.hex)
    end
  end

  describe '#normalized' do
    let(:result) { inputs.normalized }

    context 'with invalid inputs' do
      let(:args) { nil }

      it 'raises an error' do
        expect { result }.to raise_error ArgumentError
      end
    end

    context 'with non-hash inputs' do
      let(:args) { [%i[k v]] }

      it 'raises an error' do
        expect { result }.to raise_error ArgumentError
      end
    end

    context 'with ActionController::Parameters inputs' do
      let(:args) { ::ActionController::Parameters.new }

      it 'does not raise an error' do
        expect { result }.to_not raise_error
      end
    end

    context 'with simple inputs' do
      before { args[:key] = :value }

      it 'sends them straight through' do
        expect(result).to eql args
      end
    end

    context 'with groupable inputs' do
      context 'without a matching simple input' do
        before do
          args.merge!(
            'key(1i)' => :value1,
            'key(2i)' => :value2
          )
        end

        it 'groups the inputs into a GroupedInput' do
          expect(result).to eq(
            key: ActiveInteraction::GroupedInput.new(
              '1' => :value1,
              '2' => :value2
            )
          )
        end
      end

      context 'with a matching simple input' do
        before do
          args.merge!(
            'key(1i)' => :value1,
            key: :value2
          )
        end

        it 'groups the inputs into a GroupedInput' do
          expect(result).to eq(
            key: ActiveInteraction::GroupedInput.new(
              '1' => :value1
            )
          )
        end
      end
    end

    context 'with a reserved name' do
      before { args[:_interaction_key] = :value }

      it 'skips the input' do
        expect(result).to_not have_key(:_interaction_key)
      end
    end
  end

  describe '#given?' do
    let(:base_class) do
      Class.new(ActiveInteraction::Base) do
        float :x,
          default: nil

        def execute; end
      end
    end

    it 'is false when the input is not given' do
      expect(inputs.given?(:x)).to be false
    end

    it 'is true when the input is nil' do
      args[:x] = nil
      expect(inputs.given?(:x)).to be true
    end

    it 'is true when the input is given' do
      args[:x] = rand
      expect(inputs.given?(:x)).to be true
    end

    it 'symbolizes its argument' do
      args[:x] = rand
      expect(inputs.given?('x')).to be true
    end

    it 'only tracks inputs with filters' do
      args[:y] = rand
      expect(inputs.given?(:y)).to be false
    end

    context 'nested hash values' do
      let(:base_class) do
        Class.new(ActiveInteraction::Base) do
          hash :x, default: {} do
            boolean :y,
              default: true
          end

          def execute; end
        end
      end

      it 'is true when the nested inputs symbols are given' do
        described_class.class_exec do
          def execute
            given?(:x, :y)
          end
        end

        args[:x] = { y: false }
        expect(inputs.given?(:x, :y)).to be true
      end

      it 'is true when the nested inputs strings are given' do
        args['x'] = { 'y' => false }
        expect(inputs.given?(:x, :y)).to be true
      end

      it 'is false when the nested input is not given' do
        args[:x] = {}
        expect(inputs.given?(:x, :y)).to be false
      end

      it 'is false when the first input is not given' do
        expect(inputs.given?(:x, :y)).to be false
      end

      it 'is false when the first input is nil' do
        args[:x] = nil
        expect(inputs.given?(:x, :y)).to be false
      end

      it 'returns false if you go too far' do
        args[:x] = { y: true }
        expect(inputs.given?(:x, :y, :z)).to be false
      end
    end

    context 'nested array values' do
      let(:base_class) do
        Class.new(ActiveInteraction::Base) do
          array :x do
            hash do
              boolean :y, default: true
            end
          end

          def execute; end
        end
      end

      context 'has a positive index' do
        it 'returns true if found' do
          args[:x] = [{ y: true }]
          expect(inputs.given?(:x, 0, :y)).to be true
        end

        it 'returns false if not found' do
          args[:x] = []
          expect(inputs.given?(:x, 0, :y)).to be false
        end
      end

      context 'has a negative index' do
        it 'returns true if found' do
          args[:x] = [{ y: true }]
          expect(inputs.given?(:x, -1, :y)).to be true
        end

        it 'returns false if not found' do
          args[:x] = []
          expect(inputs.given?(:x, -1, :y)).to be false
        end
      end

      it 'returns false if you go too far' do
        args[:x] = [{}]
        expect(inputs.given?(:x, 10, :y)).to be false
      end
    end

    context 'multi-part date values' do
      let(:base_class) do
        Class.new(ActiveInteraction::Base) do
          date :thing,
            default: nil

          def execute; end
        end
      end

      it 'returns true when the input is given' do
        args.merge!(
          'thing(1i)' => '2020',
          'thing(2i)' => '12',
          'thing(3i)' => '31'
        )
        expect(inputs.given?(:thing)).to be true
      end

      it 'returns false if not found' do
        expect(inputs.given?(:thing)).to be false
      end
    end
  end
end
