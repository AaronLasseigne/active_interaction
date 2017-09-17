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

    context 'with an implicit Integer' do
      let(:value) do
        Class.new do
          def to_int
            @to_int ||= rand(1 << 16)
          end
        end.new
      end

      it 'returns an Integer' do
        expect(result).to eql value.to_int
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) + rand }

      it 'returns an Integer' do
        expect(result).to eql value.to_i
      end
    end

    context 'with a String' do
      let(:value) { '0' + rand(1 << 16).to_s }

      it 'returns an Integer' do
        expect(result).to eql Integer(value, 10)
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

    it 'supports different bases' do
      expect(described_class.new(name, base: 8).cast('071', nil)).to eql 57
      expect do
        described_class.new(name, base: 8).cast('081', nil)
      end.to raise_error ActiveInteraction::InvalidValueError
    end
  end

  describe '#database_column_type' do
    it 'returns :integer' do
      expect(filter.database_column_type).to eql :integer
    end
  end
end
