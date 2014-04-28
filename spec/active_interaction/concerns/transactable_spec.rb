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
      expect(klass.transaction).to be_nil
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
      expect(klass.transaction?).to be_true
    end

    it 'returns the stored value' do
      klass.transaction(false)
      expect(klass.transaction?).to be_false
    end
  end

  describe '.transaction_options' do
    it 'defaults to an empty hash' do
      expect(klass.transaction_options).to eq({})
    end

    it 'returns the stored value' do
      h = { rand => rand }
      klass.transaction(klass.transaction?, h)
      expect(klass.transaction_options).to eq h
    end
  end

  describe '#transaction' do
    let(:block) { -> { value } }
    let(:options) { {} }
    let(:result) { instance.transaction(options, &block) }
    let(:value) { double }

    it 'returns the value from the block' do
      expect(result).to eq value
    end

    it 'calls ActiveRecord::Base.transaction' do
      allow(ActiveRecord::Base).to receive(:transaction)
      result
      expect(ActiveRecord::Base).to have_received(:transaction)
        .once.with(options, &block)
    end
  end
end
