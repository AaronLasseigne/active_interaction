require 'spec_helper'

describe ActiveInteraction::Hashable do
  include_context 'concerns', ActiveInteraction::Hashable

  describe '#hash(*args, &block)' do
    context 'with no arguments' do
      let(:hash) { subject.hash }

      it 'returns an Integer' do
        expect(hash).to be_an Integer
      end
    end

    context 'with arguments' do
      let(:arguments) { [:attribute, {}] }
      let(:hash) { subject.hash(*arguments) }

      before { allow(subject).to receive(:method_missing) }

      it 'calls method_missing' do
        hash
        expect(subject).to have_received(:method_missing).once
          .with(:hash, *arguments)
      end

      context 'with a block' do
        let(:block) { proc {} }
        let(:hash) { subject.hash(*arguments, &block) }

        it 'calls method_missing' do
          hash
          expect(subject).to have_received(:method_missing).once
            .with(:hash, *arguments)
        end

        it 'passes the block to method_missing' do
          allow(subject).to receive(:method_missing) do |*, &other_block|
            expect(other_block).to equal block
          end
          hash(&block)
        end
      end
    end
  end
end
