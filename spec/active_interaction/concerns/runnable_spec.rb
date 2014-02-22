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

describe ActiveInteraction::Runnable do
  include_context 'concerns', ActiveInteraction::Runnable

  shared_context 'with an error' do
    before { instance.errors.add(:base) }
  end

  shared_context 'with a validator' do
    before { klass.validate { errors.add(:base) } }
  end

  shared_context 'with #execute defined' do
    before { klass.send(:define_method, :execute) { rand } }
  end

  context 'validations' do
    describe '#runtime_errors' do
      include_context 'with an error'

      it 'is invalid' do
        instance.result = nil
        expect(instance).to_not be_valid
      end

      it 'becomes valid if errors are cleared' do
        instance.result = nil
        instance.errors.clear
        instance.result = nil
        expect(instance).to be_valid
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

    context 'with an error' do
      include_context 'with an error'

      it 'does not set the result' do
        instance.result = result
        expect(instance.result).to be_nil
      end
    end

    context 'with a validator' do
      include_context 'with a validator'

      it 'sets the result' do
        instance.result = result
        expect(instance.result).to eq result
      end
    end
  end

  describe '#valid?' do
    let(:result) { double }

    it 'returns true' do
      expect(instance).to be_valid
    end

    context 'with an error' do
      include_context 'with an error'

      it 'returns true' do
        expect(instance).to be_valid
      end
    end

    context 'with a validator' do
      include_context 'with a validator'

      it 'returns false' do
        expect(instance).to_not be_valid
      end

      it 'does not duplicate errors on subsequent calls' do
        instance.valid?
        expect { instance.valid? }.to_not change { instance.errors.count }.by 1
      end
    end
  end

  describe '.run' do
    let(:outcome) { klass.run }

    it 'raises an error' do
      expect { outcome }.to raise_error NotImplementedError
    end

    context 'with #execute defined' do
      include_context 'with #execute defined'

      it 'returns an instance of Runnable' do
        expect(outcome).to be_a klass
      end

      it 'sets the result' do
        expect(outcome.result).to_not be_nil
      end

      context 'with a validator' do
        include_context 'with a validator'

        it 'returns an instance of Runnable' do
          expect(outcome).to be_a klass
        end

        it 'sets the result to nil' do
          expect(outcome.result).to be_nil
        end
      end
    end

    context 'with invalid post-execution state' do
      before do
        klass.class_exec do
          attr_accessor :attribute

          validate { errors.add(:attribute) if attribute }

          def execute
            self.attribute = true
          end
        end
      end

      it 'is valid' do
        expect(outcome).to be_valid
      end

      it 'stays valid' do
        outcome.attribute = true
        expect(outcome).to be_valid
      end
    end
  end

  describe '.run!' do
    let(:result) { klass.run! }

    it 'raises an error' do
      expect { result }.to raise_error NotImplementedError
    end

    context 'with #execute defined' do
      include_context 'with #execute defined'

      it 'returns the result' do
        expect(result).to_not be_nil
      end

      context 'with a validator' do
        include_context 'with a validator'

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidInteractionError
        end
      end
    end
  end
end
