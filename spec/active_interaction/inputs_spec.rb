require 'spec_helper'

describe ActiveInteraction::Inputs do
  subject(:inputs) { described_class.new }

  describe '.reserved?(name)' do
    it 'returns true for anything starting with "_interaction_"' do
      expect(described_class.reserved?('_interaction_')).to be_truthy
    end

    it 'returns true for existing instance methods' do
      (
        ActiveInteraction::Base.instance_methods +
        ActiveInteraction::Base.private_instance_methods
      ).each do |method|
        expect(described_class.reserved?(method)).to be_truthy
      end
    end

    it 'returns false for anything else' do
      expect(described_class.reserved?(SecureRandom.hex)).to be_falsey
    end
  end

  describe '.process(inputs)' do
    let(:inputs) { {} }
    let(:result) { described_class.process(inputs) }

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

  describe '#store' do
    it 'returns the value' do
      expect(inputs.store(:key, :value)).to eql :value
    end

    it 'adds the key/value pair' do
      inputs.store(:key, :value)

      expect(inputs).to eql(key: :value)
    end

    it 'adds the key/value pair to a group' do
      inputs.store(:key, :value, [:a])

      expect(inputs.group(:a)).to eql(key: :value)
    end
  end

  describe '#group' do
    it 'returns an empty hash' do
      expect(inputs.group(:a)).to eql({})
    end

    it 'key/value pairs in that group' do
      inputs.store(:key, :value, %i[a b])
      inputs.store(:key2, :value2, [:b])

      expect(inputs.group(:a)).to eql(key: :value)
      expect(inputs.group(:b)).to eql(key: :value, key2: :value2)
    end
  end
end
