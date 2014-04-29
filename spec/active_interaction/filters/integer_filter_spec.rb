# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::IntegerFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'with an Integer' do
      let(:value) { rand(1 << 16) }

      it 'returns the Integer' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) + rand }

      it 'returns an Integer' do
        expect(filter.cast(value)).to eq value.to_i
      end
    end

    context 'with a String' do
      let(:value) { rand(1 << 16).to_s }

      it 'returns an Integer' do
        expect(filter.cast(value)).to eq Integer(value)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'raises an error' do
        expect do
          filter.cast(value)
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :integer' do
      expect(filter.database_column_type).to eql :integer
    end
  end
end
