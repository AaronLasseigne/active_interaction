require 'spec_helper'

describe ActiveInteraction::AttrBlock do
  describe '.evaluate(&block)' do
    let(:attr_block) do
      described_class.evaluate do
        integer allow_nil: true do
          'Yeah'
        end
        boolean
      end
    end

    it "returns a new instance of #{described_class}" do
      expect(attr_block).to be_a described_class
    end

    it 'allows more than one attr method' do
      expect(attr_block.count).to eq 2
    end
  end

  describe '#each(&block)' do
    let(:attr_block) do
      described_class.evaluate do
        integer
        boolean
      end
    end

    it 'returns the attr methods broken down one by one' do
      expect(attr_block.each).to be_a Enumerator
    end
  end
end
