require 'spec_helper'

describe ActiveInteraction::ArrayAttr do
  describe '#prepare(key, value, options = {}, &block)' do
    it 'passes an Array through' do
      expect(described_class.prepare(:key, [1])).to eql [1]
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(:key, 1)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'

    context 'a block is given' do
      it 'runs the attr method on each array item' do
        output = described_class.prepare :key, ['1'] do
          integer
        end

        expect(output).to eql [1]
      end

      it 'handles nested blocks' do
        output = described_class.prepare :key, [['1']] do
          array do
            integer
          end
        end

        expect(output).to eql [[1]]
      end

      it 'raises an error if an array item does not match' do
        expect {
          described_class.prepare :key, ['a'] do
            integer
          end
        }.to raise_error ArgumentError
      end

      it 'raises an error if more than one attr requirement is listed' do
        expect {
          described_class.prepare :key, ['1'] do
            integer
            boolean
          end
        }.to raise_error ArgumentError
      end
    end
  end
end
