require 'spec_helper'

describe ActiveInteraction::FilterMethods do
  describe '.evaluate(&block)' do
    let(:filter_block) do
      described_class.evaluate do
        array allow_nil: true do
          'Block'
        end
        array
      end
    end

    it "returns a new instance of #{described_class}" do
      expect(filter_block).to be_a described_class
    end

    it 'returns more than one filter method' do
      expect(filter_block.count).to eq 2
    end
  end

  describe '#each(&block)' do
    let(:filter_block) { described_class.evaluate {} }

    it 'returns the filter methods broken down one by one' do
      expect(filter_block.each).to be_a Enumerator
    end
  end
end
