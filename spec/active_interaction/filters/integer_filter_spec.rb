require 'spec_helper'

describe ActiveInteraction::IntegerFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#process' do
    let(:result) { filter.process(value, nil) }

    context 'with an Integer' do
      let(:value) { rand(1 << 16) }

      it 'returns the Integer' do
        expect(result.value).to eql value
      end
    end

    context 'with a Numeric' do
      let(:value) { rand(1 << 16) + rand }

      it 'returns an Integer' do
        expect(result.value).to eql value.to_i
      end
    end

    context 'with a String' do
      let(:value) { rand(1 << 16).to_s }

      it 'returns an Integer' do
        expect(result.value).to eql Integer(value, 10)
      end
    end

    context 'with an invalid String' do
      let(:value) { 'invalid' }

      it 'indicates an error' do
        expect(
          result.error
        ).to be_an_instance_of ActiveInteraction::InvalidValueError
      end
    end

    context 'with an implicit String' do
      let(:value) do
        Class.new do
          def to_str
            '1'
          end
        end.new
      end

      it 'returns an Integer' do
        expect(result.value).to eql Integer(value.to_str, 10)
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
          expect(result.value).to eql options[:default]
        end
      end

      context 'required' do
        include_context 'required'

        it 'indicates an error' do
          expect(
            result.error
          ).to be_an_instance_of ActiveInteraction::MissingValueError
        end
      end
    end

    it 'supports different bases' do
      expect(
        described_class.new(name, base: 8).process('071', nil).value
      ).to eql 57
      expect(
        described_class.new(name, base: 8).process('081', nil).error
      ).to be_an_instance_of ActiveInteraction::InvalidValueError
    end
  end

  describe '#database_column_type' do
    it 'returns :integer' do
      expect(filter.database_column_type).to eql :integer
    end
  end
end
