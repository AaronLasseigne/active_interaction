# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::RangeFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value) }

    context 'with a Range' do
      let(:value) { Range.new(0, 0) }

      it 'returns the Range' do
        expect(result).to eql value
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
