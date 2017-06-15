# coding: utf-8

require 'bigdecimal'
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

    context 'with an implicit Integer' do
      let(:value) do
        Class.new do
          def to_int
            @to_int ||= rand(1 << 16)
          end
        end.new
      end

      it 'returns a Float' do
        expect(result).to eql value.to_int.to_f
      end
    end

    context 'with a Numeric' do
      let(:value) { BigDecimal.new('1.2') }

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

    context 'with a blank String' do
      let(:value) do
        Class.new do
          def to_str
            ' '
          end
        end.new
      end

      context 'optional' do
        include_context 'optional'

        it 'returns the default' do
          expect(result).to eql options[:default]
        end
      end

      context 'required' do
        include_context 'required'

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::MissingValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :float' do
      expect(filter.database_column_type).to eql :float
    end
  end
end
