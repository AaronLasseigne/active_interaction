# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::FilterColumn do
  subject(:column) { described_class.new(type) }
  let(:type) { described_class::TYPE_MAPPING.keys.first }

  describe '.new' do
    context 'type is not in TYPE_MAPPING' do
      let(:type) { SecureRandom.hex }

      it 'fails' do
        expect do
          column
        end.to raise_error ActiveInteraction::InvalidFilterColumnError
      end
    end
  end

  describe '#limit' do
    it 'returns nil' do
      expect(column.limit).to be_nil
    end
  end

  describe '#number?' do
    let(:number?) { column.number? }

    context 'type is' do
      context ':integer' do
        let(:type) { :integer }

        it 'returns true' do
          expect(number?).to be_true
        end
      end

      context ':float' do
        let(:type) { :float }

        it 'returns true' do
          expect(number?).to be_true
        end
      end

      context 'anything else' do
        let(:type) { :string }

        it 'returns false' do
          expect(number?).to be_false
        end
      end
    end
  end

  describe '#text?' do
    let(:text?) { column.text? }

    context 'type is' do
      context ':string' do
        let(:type) { :string }

        it 'returns true' do
          expect(text?).to be_true
        end
      end

      context 'anything else' do
        let(:type) { :float }

        it 'returns false' do
          expect(text?).to be_false
        end
      end
    end
  end

  describe '#type' do
    let(:type) { :float }

    it 'returns the type' do
      expect(column.type).to eql type
    end
  end
end
