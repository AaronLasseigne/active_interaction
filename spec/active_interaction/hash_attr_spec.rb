require 'spec_helper'

describe ActiveInteraction::HashAttr do
  describe '#prepare(key, value, options = {}, &block)' do
    it 'passes a Hash through' do
      expect(described_class.prepare(:key, {one: 1})).to eq({one: 1})
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(:key, 1)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'

    context 'a block is given' do
      it 'runs the attr method on each array item' do
        output = described_class.prepare :key, {one: '1'} do
          integer :one
        end

        expect(output).to eq({one: 1})
      end

      it 'handles nested blocks' do
        output = described_class.prepare :key, {one: ['1']} do
          array :one do
            integer
          end
        end

        expect(output).to eq({one: [1]})
      end

      it 'raises an error if an array item does not match' do
        expect {
          described_class.prepare :key, {one: 'a'} do
            integer :one
          end
        }.to raise_error ArgumentError
      end

      it 'allows more than one key to be listed' do
        output = described_class.prepare :key, {one: '1', two: '2.0'} do
          integer :one
          float   :two
        end

        expect(output).to eq({one: 1, two: 2.0})
      end
    end
  end
end
