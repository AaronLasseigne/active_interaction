require 'spec_helper'

describe ActiveInteraction::AttrBlock do
  describe '.evaluate(&block)' do
    let(:attrs) do
      described_class.evaluate do
        integer allow_nil: true do
          'Yeah'
        end
        boolean
      end
    end

    it "returns a new instance of #{described_class}" do
      expect(attrs).to be_a described_class
    end

    it 'sets the type of method called' do
      expect(attrs.first[0]).to eq :integer
    end

    it 'sets the options for the method' do
      expect(attrs.first[1]).to eq([{allow_nil: true}])
    end

    it 'sets the block for the method' do
      expect(attrs.first[2]).to be_a Proc
    end

    it 'allows more than one attr method' do
      expect(attrs.count).to eq 2
    end
  end

  describe '#count' do
    it 'returns the number of evaluated attr methods' do
      expect(described_class.new.count).to eq 0
    end
  end
end
