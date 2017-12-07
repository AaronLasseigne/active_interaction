require 'spec_helper'

describe ActiveInteraction::InterfaceFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before { options[:methods] = %i[dump load] }

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a matching object' do
      let(:value) do
        Class.new do
          def dump; end

          def load; end
        end.new
      end

      it 'returns a the value' do
        expect(result).to eql value
      end
    end

    context 'with an non-matching object' do
      let(:value) { Object.new }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValueError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
