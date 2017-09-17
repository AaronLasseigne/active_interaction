require 'spec_helper'

describe ActiveInteraction::DecimalFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'with digits' do
    let(:digits) { 4 }

    before do
      options[:digits] = digits
    end
  end

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a Float' do
      let(:value) { rand }

      it 'returns the BigDecimal' do
        expect(result).to eql BigDecimal.new(value, 0)
      end

      context 'with :digits option' do
        include_context 'with digits'

        let(:value) { 1.23456789 }

        it 'returns BigDecimal with given digits' do
          expect(result).to eql BigDecimal.new('1.235')
        end
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

      it 'returns a BigDecimal' do
        expect(result).to eql BigDecimal.new(value.to_int)
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) }

      it 'returns a BigDecimal' do
        expect(result).to eql BigDecimal.new(value)
      end
    end

    context 'with a String' do
      let(:value) { rand.to_s }

      it 'returns a BigDecimal' do
        expect(result).to eql BigDecimal.new(value)
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

    context 'with an invalid implicit String' do
      let(:value) do
        Class.new do
          def to_str
            'invalid'
          end
        end.new
      end

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
    it 'returns :decimal' do
      expect(filter.database_column_type).to eql :decimal
    end
  end
end
