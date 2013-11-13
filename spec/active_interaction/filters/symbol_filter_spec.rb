require 'spec_helper'

describe ActiveInteraction::SymbolFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'with a Symbol' do
      let(:value) { SecureRandom.hex.to_sym }

      it 'returns the Symbol' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns a Symbol' do
        expect(filter.cast(value)).to eq value.to_sym
      end
    end
  end
end
