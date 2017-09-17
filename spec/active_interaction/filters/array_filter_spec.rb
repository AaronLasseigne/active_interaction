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

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with an Array' do
      let(:value) { [] }

      it 'returns the Array' do
        expect(result).to eql value
      end
    end

    context 'with an implicit Array' do
      let(:value) do
        Class.new do
          def to_ary
            [1, 2, 3]
          end
        end.new
      end

      it 'returns the Array' do
        expect(result).to eql value.to_ary
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

    context 'with a nested object filter' do
      let(:block) { proc { object } }
      let(:name) { :objects }
      let(:value) { [Object.new] }

      it 'does not raise an error' do
        expect { result }.to_not raise_error
      end

      it 'has a filter with the right key' do
        expect(filter.filters).to have_key(:object)
      end

      it 'has a filter with the right name' do
        expect(filter.filters[:object].name).to eql(:object)
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
