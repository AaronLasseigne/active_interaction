require 'active_interaction'

describe ActiveInteraction::BooleanAttr do
  describe '#prepare(value, options = {})' do
    it 'sets `true` to `true`' do
      expect(described_class.prepare(true)).to eq true
    end

    it 'sets `false` to `false`' do
      expect(described_class.prepare(false)).to eq false
    end

    it 'sets "1" to `true`' do
      expect(described_class.prepare('1')).to eq true
    end

    it 'sets "0" to `false`' do
      expect(described_class.prepare('0')).to eq false
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
