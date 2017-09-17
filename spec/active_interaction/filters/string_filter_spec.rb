require 'spec_helper'

describe ActiveInteraction::StringFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'without strip' do
    before do
      options[:strip] = false
    end
  end

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns the String' do
        expect(result).to eql value
      end
    end

    context 'with a strippable String' do
      let(:value) { " #{SecureRandom.hex} " }

      it 'returns the stripped string' do
        expect(result).to eql value.strip
      end

      context 'without strip' do
        include_context 'without strip'

        it 'returns the String' do
          expect(result).to eql value
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
