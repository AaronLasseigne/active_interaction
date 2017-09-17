require 'spec_helper'

describe ActiveInteraction::FloatFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a Float' do
      let(:value) { rand }

      it 'returns the Float' do
        expect(result).to eql value
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) }

      it 'returns a Float' do
        expect(result).to eql value.to_f
      end
    end

    context 'with a String' do
      let(:value) { rand.to_s }

      it 'returns a Float' do
        expect(result).to eql Float(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect do
          result
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :float' do
      expect(filter.database_column_type).to eql :float
    end
  end
end
