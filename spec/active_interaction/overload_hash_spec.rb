require 'spec_helper'

describe ActiveInteraction::OverloadHash do
  let(:subject) { double.extend(ActiveInteraction::OverloadHash) }

  describe '#hash(*args, &block)' do
    context 'when no arguments are passed it acts like the standard hash method' do
      it 'returns a fixnum' do
        expect(subject.hash).to be_a Fixnum
      end
    end

    context 'when arguments are passed it works as a filter method' do
      before { allow(subject).to receive(:method_missing) }

      it 'gets sent to method_missing' do
        subject.hash(:attr_name, {}) do
          'Block'
        end

        expect(subject).to have_received(:method_missing).once.with(:hash, :attr_name, kind_of(Hash)) # TODO: find out how to check for blocks
      end

      it 'gets sent to add_filter_methods with no block' do
        subject.hash(:attr_name, {})

        expect(subject).to have_received(:method_missing).once.with(:hash, :attr_name, kind_of(Hash))
      end
    end
  end
end
