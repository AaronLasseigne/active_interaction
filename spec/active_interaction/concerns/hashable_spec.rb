require 'spec_helper'

describe ActiveInteraction::Hashable do
  include_context 'concerns', described_class

  describe '#hash(*args, &block)' do
    context 'with no arguments' do
      let(:hash) { instance.hash }

      it 'returns an Integer' do
        expect(hash).to be_an Integer
      end
    end

    context 'with arguments' do
      let(:arguments) { [:attribute, {}] }
      let(:hash) { instance.hash(*arguments) }

      before { allow(instance).to receive(:method_missing) }

      it 'calls method_missing' do
        hash
        expect(instance).to have_received(:method_missing).once
          .with(:hash, *arguments)
      end

      context 'with a block' do
        let(:block) { proc {} }
        let(:hash) { instance.hash(*arguments, &block) }

        it 'calls method_missing' do
          hash
          expect(instance).to have_received(:method_missing).once
            .with(:hash, *arguments)
        end

        it 'passes the block to method_missing' do
          allow(instance).to receive(:method_missing) do |*, &other_block|
            expect(other_block).to equal block
          end
          hash(&block)
        end
      end
    end
  end
end
