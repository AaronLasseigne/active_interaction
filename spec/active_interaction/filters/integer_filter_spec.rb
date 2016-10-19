# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::IntegerFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with an Integer' do
      let(:value) { rand(1 << 16) }

      it 'returns the Integer' do
        expect(result).to eql value
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) + rand }

      it 'returns an Integer' do
        expect(result).to eql value.to_i
      end
    end

    context 'with a String' do
      let(:value) { rand(1 << 16).to_s }

      it 'returns an Integer' do
        expect(result).to eql Integer(value)
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

    it 'supports different bases' do
      expect(filter.cast('07', nil)).to eql 7
      expect do
        filter.cast('08', nil)
      end.to raise_error ActiveInteraction::InvalidValueError
      expect(described_class.new(name, base: 10).cast('08', nil)).to eql 8
    end
  end

  describe '#database_column_type' do
    it 'returns :integer' do
      expect(filter.database_column_type).to eql :integer
    end
  end
end
