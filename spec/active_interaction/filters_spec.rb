require 'spec_helper'

describe ActiveInteraction::Filters do
  let(:block) { Proc.new {} }
  subject(:filters) { described_class.evaluate(&block) }

  describe '.evaluate(&block)' do
    it "returns an instance of #{described_class}" do
      expect(filters).to be_a described_class
    end

    it 'does not add any filter methods' do
      expect(filters.count).to eq 0
    end

    context 'with a filter method' do
      let(:block) { Proc.new { boolean } }

      it 'adds a filter method' do
        expect(filters.count).to eq 1
      end
    end
  end

  describe '#each' do
    it 'returns an Enumerator' do
      expect(filters.each).to be_an Enumerator
    end
  end
end
