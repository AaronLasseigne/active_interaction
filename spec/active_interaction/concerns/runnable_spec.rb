# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Runnable do
  include_context 'concerns', ActiveInteraction::Runnable

  class WrappableFailingInteraction
    include ActiveInteraction::Runnable

    def execute
      errors.add(:base)
    end
  end

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

  context 'callbacks' do
    describe '.set_callback' do
      include_context 'with #execute defined'

      shared_examples 'set_callback examples' do |name|
        context name do
          it 'does not raise an error' do
            expect do
              klass.set_callback name, :before, -> {}
            end.to_not raise_error
          end

          %i[after around before].each do |type|
            it type do
              has_run = false

              klass.set_callback name, type, -> { has_run = true }

              klass.run
              expect(has_run).to be_truthy
            end
          end
        end
      end

      include_examples 'set_callback examples', :validate
      include_examples 'set_callback examples', :execute

      context 'execute with composed interaction' do
        class WithFailingCompose
          include ActiveInteraction::Runnable

          def execute
            compose(WrappableFailingInteraction)
          end
        end

        context 'around' do
          it 'is yielded errors from composed interactions' do
            block_result = nil
            WithFailingCompose.set_callback :execute, :around do |_, block|
              block_result = block.call
            end

            WithFailingCompose.run
            expect(block_result).to be_an(ActiveInteraction::Errors)
            expect(block_result).to include(:base)
          end
        end

        context 'after' do
          it 'is yielded errors from composed interactions' do
            has_run = false
            WithFailingCompose.set_callback :execute, :after do
              has_run = true
            end

            WithFailingCompose.run
            expect(has_run).to be_truthy
          end

          context 'using if' do
            it 'yields errors to the if' do
              has_run = false
              # rubocop:disable Metic/LineLength
              WithFailingCompose.set_callback :execute, :after, if: -> { errors.any? } do
                has_run = true
              end
              # rubocop:enable Metic/LineLength

              WithFailingCompose.run
              expect(has_run).to be_truthy
            end
          end
        end
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
      expect((instance.result = result)).to eql result
    end

    it 'sets the result' do
      instance.result = result
      expect(instance.result).to eql result
    end

    context 'with an error' do
      include_context 'with an error'

      it 'sets the result' do
        instance.result = result
        expect(instance.result).to eql result
      end
    end

    context 'with a validator' do
      include_context 'with a validator'

      it 'sets the result' do
        instance.result = result
        expect(instance.result).to eql result
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
        count = instance.errors.count
        instance.valid?

        expect(instance.errors.count).to eql count
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

    context 'caches the validity and result of the run' do
      let(:klass) do
        Class.new(ActiveInteraction::Base) do
          INVALID = [false, true].cycle

          validate do |interaction|
            interaction.errors.add(:base, 'failed') unless INVALID.next
          end

          def execute
            true
          end
        end
      end

      it 'is invalid' do
        expect(outcome).to_not be_valid
        expect(outcome.result).to be_nil
        expect(outcome).to_not be_valid
        expect(outcome.result).to be_nil
      end
    end

    context 'caches the validity and result of the run' do
      let(:klass) do
        Class.new(ActiveInteraction::Base) do
          VALID = [true, false].cycle

          validate do |interaction|
            interaction.errors.add(:base, 'failed') unless VALID.next
          end

          def execute
            true
          end
        end
      end

      it 'is valid' do
        expect(outcome).to be_valid
        expect(outcome.result).to be true
        expect(outcome).to be_valid
        expect(outcome.result).to be true
      end
    end

    context 'with valid post-execution state' do
      before do
        klass.class_exec do
          attr_accessor :attribute

          validate { errors.add(:attribute) unless attribute }

          def execute
            self.attribute = true
          end
        end
      end

      it 'is invalid' do
        expect(outcome).to_not be_valid
      end

      it 'stays invalid' do
        outcome.attribute = false
        expect(outcome).to_not be_valid
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

    context 'with failing composition' do
      class CheckInnerForFailure
        include ActiveInteraction::Runnable

        attr_reader :caught_error

        def execute
          compose(WrappableFailingInteraction)
        rescue
          @caught_error = true
          raise
        end
      end

      it 'throws an error from the inner interaction' do
        outcome = CheckInnerForFailure.run
        expect(outcome.caught_error).to be true
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
