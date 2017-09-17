require 'spec_helper'

describe ActiveInteraction::SymbolFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a Symbol' do
      let(:value) { SecureRandom.hex.to_sym }

      it 'returns the Symbol' do
        expect(result).to eql value
      end
    end

    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns a Symbol' do
        expect(result).to eql value.to_sym
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
