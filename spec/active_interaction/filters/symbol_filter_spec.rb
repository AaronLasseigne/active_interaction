require 'spec_helper'

describe ActiveInteraction::SymbolFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#process' do
    let(:result) { filter.process(value, nil) }

    context 'with a Symbol' do
      let(:value) { SecureRandom.hex.to_sym }

      it 'returns the Symbol' do
        expect(result.value).to eql value
      end
    end

    context 'with an implicit Symbol' do
      let(:value) do
        Class.new do
          def to_sym
            :symbol
          end
        end.new
      end

      it 'returns a symbol' do
        expect(result.value).to eql value.to_sym
      end
    end

    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns a Symbol' do
        expect(result.value).to eql value.to_sym
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to be :string
    end
  end
end
