require 'spec_helper'
require 'json'
require 'yaml'

describe ActiveInteraction::InterfaceFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before { options[:methods] = %i[dump load] }

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a BasicObject' do
      let(:value) { BasicObject.new }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValueError
      end
    end

    context 'with an Object' do
      let(:value) { Object.new }

      it 'raises an error' do
        expect { result }.to raise_error ActiveInteraction::InvalidValueError
      end
    end

    context 'with JSON' do
      let(:value) { JSON }

      it 'returns an Array' do
        expect(result).to eql value
      end
    end

    context 'with YAML' do
      let(:value) { YAML }

      it 'returns an Hash' do
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
