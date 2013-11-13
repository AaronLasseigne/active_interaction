require 'spec_helper'

describe ActiveInteraction::SymbolInput, :input do
  let(:name) { SecureRandom.hex.to_sym }
  let(:options) { {} }

  subject(:input) { described_class.new(name, options) }

  describe '#cast' do
    context do
      let(:value) { SecureRandom.hex.to_sym }

      it do
        expect(input.cast(value)).to eq value
      end
    end

    context do
      let(:value) { SecureRandom.hex }

      it do
        expect(input.cast(value)).to eq value.to_sym
      end
    end
  end
end
