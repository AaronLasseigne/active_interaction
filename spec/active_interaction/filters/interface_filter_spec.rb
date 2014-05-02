# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::InterfaceFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before { options[:methods] = [:each] }

  describe '#cast' do
    let(:result) { filter.cast(value) }

    context 'with an Object' do
      let(:value) { Object.new }

      it 'raises an error' do
        expect do
          result
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end

    context 'with an Array' do
      let(:value) { [] }

      it 'returns an Array' do
        expect(result).to eql value
      end
    end

    context 'with an Hash' do
      let(:value) { {} }

      it 'returns an Hash' do
        expect(result).to eql value
      end
    end

    context 'with an Range' do
      let(:value) { (0..0) }

      it 'returns an Range' do
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
