# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::DecimalFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with digits' do
    let(:digits) { 4 }

    before do
      options.merge!(digits: digits)
    end
  end

  describe '#cast' do
    context 'with a Float' do
      let(:value) { rand }

      it 'returns the BigDecimal' do
        expect(filter.cast(value)).to eql BigDecimal.new(value, 0)
      end

      context 'with :digits option' do
        include_context 'with digits'

        let(:value) { 1.23456789 }

        it 'returns BigDecimal with given digits' do
          expect(filter.cast(value)).to eql BigDecimal.new('1.235')
        end
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) }

      it 'returns a BigDecimal' do
        expect(filter.cast(value)).to eql BigDecimal.new(value)
      end
    end

    context 'with a String' do
      let(:value) { rand.to_s }

      it 'returns a BigDecimal' do
        expect(filter.cast(value)).to eql BigDecimal.new(value)
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
    it 'returns :decimal' do
      expect(filter.database_column_type).to eql :decimal
    end
  end
end
