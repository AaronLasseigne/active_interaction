# coding: utf-8

require 'spec_helper'

describe ActiveRecord::Base do
  describe '.transaction' do
    it 'raises an error' do
      expect { described_class.transaction }.to raise_error LocalJumpError
    end

    it 'silently rescues ActiveRecord::Rollback' do
      expect do
        described_class.transaction do
          fail ActiveRecord::Rollback
        end
      end.to_not raise_error
    end

    context 'with a block' do
      it 'yields to the block' do
        expect { |b| described_class.transaction(&b) }.to yield_with_no_args
      end

      it 'accepts an argument' do
        expect { described_class.transaction(nil) {} }.to_not raise_error
      end
    end
  end
end

describe ActiveInteraction::Transactable do
  include_context 'concerns', ActiveInteraction::Transactable

  describe '.transaction' do
    it 'returns nil' do
      expect(klass.transaction(true)).to be_nil
    end

    it 'accepts a flag parameter' do
      expect { klass.transaction(true) }.to_not raise_error
    end

    it 'also accepts an options parameter' do
      expect { klass.transaction(true, {}) }.to_not raise_error
    end
  end

  describe '.transaction?' do
    it 'defaults to true' do
      expect(klass.transaction?).to be_truthy
    end

    it 'returns the stored value' do
      klass.transaction(false)
      expect(klass.transaction?).to be_falsey
    end

    context 'with a subclass' do
      before { klass.transaction(false) }

      let(:subclass) { Class.new(klass) }

      it 'inherits from the superclass' do
        expect(subclass.transaction?).to be_falsey
      end
    end
  end

  describe '.transaction_options' do
    let(:h) { { rand => rand } }

    it 'defaults to an empty hash' do
      expect(klass.transaction_options).to eql({})
    end

    it 'returns the stored value' do
      klass.transaction(klass.transaction?, h)
      expect(klass.transaction_options).to eql h
    end

    context 'with a subclass' do
      before { klass.transaction(klass.transaction?, h) }

      let(:subclass) { Class.new(klass) }

      it 'inherits from the superclass' do
        expect(subclass.transaction_options).to eql h
      end
    end
  end

  describe '#transaction' do
    let(:block) { -> { value } }
    let(:result) { instance.transaction(&block) }
    let(:value) { double }

    before do
      allow(ActiveRecord::Base).to receive(:transaction).and_call_original
    end

    it 'returns nil' do
      expect(instance.transaction).to be_nil
    end

    context 'with transactions disabled' do
      before do
        klass.transaction(false)
      end

      it 'returns the value of the block' do
        expect(result).to eql value
      end

      it 'does not call ActiveRecord::Base.transaction' do
        expect(ActiveRecord::Base).to_not have_received(:transaction)
      end
    end

    context 'with transactions enabled' do
      before do
        klass.transaction(true)
      end

      it 'returns the value of the block' do
        expect(result).to eql value
      end

      it 'calls ActiveRecord::Base.transaction' do
        result
        expect(ActiveRecord::Base).to have_received(:transaction)
          .once.with(klass.transaction_options, &block)
      end
    end
  end
end
