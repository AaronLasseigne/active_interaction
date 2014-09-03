# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::ArrayFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  context 'with multiple nested filters' do
    let(:block) do
      proc do
        array
        array
      end
    end

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  context 'with a nested name' do
    let(:block) { proc { array :a } }

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  context 'with a nested default' do
    let(:block) { proc { array default: nil } }

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidDefaultError
    end
  end

  describe '#clean' do
    let(:result) { filter.clean(value, instance) }

    context 'with an Array' do
      let(:value) { [] }

      it 'returns the Array' do
        expect(result).to eql value
      end
    end

    context 'with a heterogenous Array' do
      let(:value) { [[], false, 0.0, {}, 0, '', :''] }

      it 'returns the Array' do
        expect(result).to eql value
      end
    end

    context 'with a nested filter' do
      let(:block) { proc { array } }

      context 'with an Array' do
        let(:value) { [] }

        it 'returns the Array' do
          expect(result).to eql value
        end
      end

      context 'with an Array of Arrays' do
        let(:value) { [[]] }

        it 'returns the Array' do
          expect(result).to eql value
        end
      end

      context 'with a heterogenous Array' do
        let(:value) { [[], false, 0.0, {}, 0, '', :''] }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
