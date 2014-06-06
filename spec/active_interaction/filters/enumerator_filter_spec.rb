# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::EnumeratorFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value) }

    context 'with a Enumerator' do
      let(:value) { Enumerator.new { |_| } }

      it 'returns the Enumerator' do
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
