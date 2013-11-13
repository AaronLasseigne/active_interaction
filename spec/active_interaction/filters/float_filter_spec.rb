require 'spec_helper'

describe ActiveInteraction::FloatFilter, :filter do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:filter) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { rand }

      it do
        expect(filter.cast(value)).to eq value
      end
    end

    context do
      let(:value) { rand(1 << 16) }

      it do
        expect(filter.cast(value)).to eq value.to_f
      end
    end

    context do
      let(:value) { rand.to_s }

      it do
        expect(filter.cast(value)).to eq Float(value)
      end
    end

    context do
      let(:value) { 'invalid' }

      it do
        expect { filter.cast(value) }.to raise_error(ActiveInteraction::InvalidValue)
      end
    end
  end
end
