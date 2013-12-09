# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::HashFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  context 'with a nested nameless filter' do
    let(:block) { proc { hash } }

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  describe '#cast' do
    context 'with a Hash' do
      let(:value) { {} }

      it 'returns the Hash' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with a non-empty Hash' do
      let(:value) { { a: {} } }

      it 'returns an empty Hash' do
        expect(filter.cast(value)).to eq({})
      end
    end

    context 'with a nested filter' do
      let(:block) { proc { hash :a } }

      context 'with a Hash' do
        let(:value) { { a: {} } }

        it 'returns the Hash' do
          expect(filter.cast(value)).to eq value
        end

        context 'with String keys' do
          before do
            value.stringify_keys!
          end

          it 'does not raise an error' do
            expect { filter.cast(value) }.to_not raise_error
          end
        end
      end
    end
  end

  describe '#default' do
    context 'with a Hash' do
      before do
        options.merge!(default: {})
      end

      it 'returns the Hash' do
        expect(filter.default).to eq options[:default]
      end
    end

    context 'with a non-empty Hash' do
      before do
        options.merge!(default: { a: {} })
      end

      it 'raises an error' do
        expect do
          filter.default
        end.to raise_error ActiveInteraction::InvalidDefaultError
      end
    end
  end
end
