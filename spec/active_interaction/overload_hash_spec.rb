require 'spec_helper'

describe ActiveInteraction::OverloadHash do
  subject { double.extend(described_class) }

  describe '#hash(*args, &block)' do
    context 'with no arguments' do
      let(:hash) { subject.hash }

      it 'returns a Fixnum' do
        expect(hash).to be_a Fixnum
      end
    end

    context 'with arguments' do
      let(:arguments) { [:attribute, {}] }
      let(:hash) { subject.hash(*arguments) }

      before { allow(subject).to receive(:method_missing) }

      it 'calls method_missing' do
        hash
        expect(subject).to have_received(:method_missing).once.
          with(:hash, *arguments)
      end

      context 'with a block' do
        let(:block) { Proc.new {} }
        let(:hash) { subject.hash(*arguments, &block) }

        it 'calls method_missing' do
          hash
          expect(subject).to have_received(:method_missing).once.
            with(:hash, *arguments)
        end

        it 'passes the block to method_missing'
      end
    end
  end
end
