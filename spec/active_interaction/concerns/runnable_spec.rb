# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Runnable do
  let(:klass) do
    Class.new do
      include ActiveModel::Validations
      include ActiveInteraction::Runnable

      def self.name
        SecureRandom.hex
      end
    end
  end

  subject(:instance) { klass.new }

  describe 'ActiveRecord::Base.transaction' do
    it 'raises an error' do
      expect { ActiveRecord::Base.transaction }.to raise_error LocalJumpError
    end

    context 'with a block' do
      let(:block) { -> {} }

      it 'yields to the block' do
        expect do |block|
          ActiveRecord::Base.transaction(&block)
        end.to yield_with_no_args
      end

      it 'accepts an argument' do
        expect do
          ActiveRecord::Base.transaction(nil, &block)
        end.to_not raise_error
      end
    end
  end

  describe '#errors' do
    it 'returns the errors' do
      expect(instance.errors).to be_an ActiveInteraction::Errors
    end
  end

  describe '#execute' do
    it 'raises an error' do
      expect { instance.execute }.to raise_error NotImplementedError
    end
  end

  describe '#result' do
    it 'returns the result' do
      expect(instance.result).to be_nil
    end
  end

  describe '#result=' do
    let(:result) { double }

    it 'returns the result' do
      expect(instance.result = result).to eq result
    end

    it 'sets the result' do
      instance.result = result
      expect(instance.result).to eq result
    end

    context 'invalid' do
      before do
        allow(instance.errors).to receive(:empty?).and_return(false)
      end

      it 'does not set the result' do
        instance.result = result
        expect(instance.result).to be_nil
      end
    end
  end

  describe '#valid?' do
    it 'returns true' do
      expect(instance.valid?).to be_true
    end

    context 'invalid' do
      let(:result) { double }

      before do
        klass.validate { errors.add(:base) }
        instance.result = result
      end

      it 'returns nil' do
        expect(instance.valid?).to be_nil
      end

      it 'sets the result to nil' do
        instance.valid?
        expect(instance.result).to be_nil
      end
    end
  end

  describe '.run' do
    let(:outcome) { klass.run }

    it 'raises an error' do
      expect { outcome }.to raise_error NotImplementedError
    end

    context 'with #execute' do
      let(:result) { double }

      before do
        allow_any_instance_of(klass).to receive(:execute).and_return(result)
      end

      it 'calls #execute' do
        expect_any_instance_of(klass).to receive(:execute).with(no_args)
        outcome
      end

      it 'returns an instance of Runnable' do
        expect(outcome).to be_a klass
      end

      it 'sets the result' do
        expect(outcome.result).to eq result
      end

      context 'with #valid?' do
        before do
          allow_any_instance_of(klass).to receive(:valid?).and_return(false)
        end

        it 'calls #valid?' do
          expect_any_instance_of(klass).to receive(:valid?).with(no_args)
          outcome
        end

        it 'returns an instance of Runnable' do
          expect(outcome).to be_a klass
        end

        it 'sets the result to nil' do
          expect(outcome.result).to be_nil
        end
      end
    end
  end

  describe '.run!' do
    let(:result) { klass.run! }

    it 'raises an error' do
      expect { result }.to raise_error NotImplementedError
    end

    context 'with .run' do
      let(:outcome) { instance }

      before do
        allow(klass).to receive(:run).and_return(outcome)
      end

      it 'calls .run' do
        result
        expect(klass).to have_received(:run).with(no_args)
      end

      it 'returns the result' do
        expect(result).to eq instance.result
      end

      context 'with #valid?' do
        before do
          allow(instance).to receive(:valid?).and_return(false)
        end

        it 'calls #valid?' do
          begin
            result
          rescue
            expect(instance).to have_received(:valid?).with(no_args)
          end
        end

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidInteractionError
        end
      end
    end
  end
end
