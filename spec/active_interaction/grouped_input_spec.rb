RSpec.describe ActiveInteraction::GroupedInput do
  describe '.new' do
    it 'adds all values to the object' do
      grouped_input = described_class.new('1' => 1, '2' => 2)

      expect(grouped_input['1']).to be 1
      expect(grouped_input['2']).to be 2
    end
  end

  describe '#[]' do
    it 'returns nil if the key does not exist' do
      grouped_input = described_class.new

      expect(grouped_input['1']).to be_nil
    end

    it 'returns a value if the key exists' do
      grouped_input = described_class.new('1' => 1)

      expect(grouped_input['1']).to be 1
    end
  end

  describe '#[]=' do
    it 'sets the key does not exist' do
      grouped_input = described_class.new

      expect(grouped_input['1'] = 1).to be 1
      expect(grouped_input['1']).to be 1
    end
  end
end
