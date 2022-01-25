require 'spec_helper'

describe ActiveInteraction::Inputs do
  subject(:inputs) { described_class.new }

  describe '.reserved?(name)' do
    it 'returns true for anything starting with "_interaction_"' do
      expect(described_class.reserved?('_interaction_')).to be_truthy
    end

    it 'returns true for existing instance methods' do
      (
        (ActiveInteraction::Base.instance_methods - Object.instance_methods) +
        (ActiveInteraction::Base.private_instance_methods - Object.private_instance_methods)
      ).each do |method|
        expect(described_class.reserved?(method)).to be_truthy
      end
    end

    it 'returns false for anything else' do
      expect(described_class.reserved?(SecureRandom.hex)).to be_falsey
    end
  end

  describe '.normalize(inputs)' do
    let(:inputs) { {} }
    let(:result) { described_class.normalize(inputs) }

    context 'with invalid inputs' do
      let(:inputs) { nil }

      it 'raises an error' do
        expect { result }.to raise_error ArgumentError
      end
    end

    context 'with non-hash inputs' do
      let(:inputs) { [%i[k v]] }

      it 'raises an error' do
        expect { result }.to raise_error ArgumentError
      end
    end

    context 'with ActionController::Parameters inputs' do
      let(:inputs) { ActionController::Parameters.new }

      it 'does not raise an error' do
        expect { result }.to_not raise_error
      end
    end

    context 'with simple inputs' do
      before { inputs[:key] = :value }

      it 'sends them straight through' do
        expect(result).to eql inputs
      end
    end

    context 'with groupable inputs' do
      context 'without a matching simple input' do
        before do
          inputs.merge!(
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
          inputs.merge!(
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
      before { inputs[:_interaction_key] = :value }

      it 'skips the input' do
        expect(result).to_not have_key(:_interaction_key)
      end
    end
  end
end
