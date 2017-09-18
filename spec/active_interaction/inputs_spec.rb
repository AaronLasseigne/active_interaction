require 'spec_helper'

describe ActiveInteraction::Inputs do
  subject(:inputs) { described_class.new }

  describe '#store' do
    it 'returns the value' do
      expect(inputs.store(:key, :value)).to eql :value
    end

    it 'adds the key/value pair' do
      inputs.store(:key, :value)

      expect(inputs).to eql(key: :value)
    end

    it 'adds the key/value pair to a group' do
      inputs.store(:key, :value, [:a])

      expect(inputs.group(:a)).to eql(key: :value)
    end
  end

  describe '#group' do
    it 'returns an empty hash' do
      expect(inputs.group(:a)).to eql({})
    end

    it 'key/value pairs in that group' do
      inputs.store(:key, :value, %i[a b])
      inputs.store(:key2, :value2, [:b])

      expect(inputs.group(:a)).to eql(key: :value)
      expect(inputs.group(:b)).to eql(key: :value, key2: :value2)
    end
  end
end
