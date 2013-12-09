# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::StringFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  shared_context 'without strip' do
    before do
      options.merge!(strip: false)
    end
  end

  describe '#cast' do
    context 'with a String' do
      let(:value) { SecureRandom.hex }

      it 'returns the String' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a strippable String' do
      let(:value) { " #{SecureRandom.hex} " }

      it 'returns the stripped string' do
        expect(filter.cast(value)).to eq value.strip
      end

      context 'without strip' do
        include_context 'without strip'

        it 'returns the String' do
          expect(filter.cast(value)).to eq value
        end
      end
    end
  end
end
