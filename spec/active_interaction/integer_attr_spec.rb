require 'active_interaction'

describe ActiveInteraction::IntegerAttr do
  describe '#prepare(value, options = {})' do
    context 'value is a String' do
      it 'converts Strings that are only digits' do
        expect(described_class.prepare('1')).to eq 1
      end
    end

    context 'value is an Integer' do
      it 'passes it on through' do
        expect(described_class.prepare(1)).to eq 1
      end
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(true)
      }.to raise_error ArgumentError
    end

    context 'options' do
      context ':allow_nil' do
        context 'is true' do
          it 'allows the options to be set to nil' do
            expect(described_class.prepare(nil, allow_nil: true)).to eq nil
          end
        end

        context 'is false' do
          it 'throws an error' do
            expect {
              described_class.prepare(nil, allow_nil: false)
            }.to raise_error ArgumentError
          end
        end
      end
    end
  end
end
