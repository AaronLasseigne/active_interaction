require 'spec_helper'

shared_examples 'validations pass' do |method|
  context 'validations pass' do
    subject(:outcome) { SubBase.send(method, valid: true) }

    it 'sets `response` to the value of `execute`' do
      expect(outcome.response).to eq 'Execute!'
    end
  end
end

describe ActiveInteraction::Base do
  class ExampleInteraction < ActiveInteraction::Base; end

  subject(:base) { ExampleInteraction.new }

  class SubBase < described_class
    attr_reader :valid

    validates :valid,
      inclusion: {in: [true]}

    def execute
      'Execute!'
    end
  end

  describe '.new(options = {})' do
    it 'sets the attributes on the return value based on the options passed' do
      expect(SubBase.new(valid: true).valid).to eq true
    end

    it 'does not allow :response as a option' do
      expect {
        SubBase.new(response: true)
      }.to raise_error ArgumentError
    end
  end

  describe '.run(options = {})' do
    it_behaves_like 'validations pass', :run

    context 'validations fail' do
      subject(:outcome) { SubBase.run(valid: false) }

      it 'sets response to nil' do
        expect(outcome.response).to be_nil
      end
    end
  end

  describe '.run!(options = {})' do
    it_behaves_like 'validations pass', :run!

    context 'validations fail' do
      it 'throws an error' do
        expect {
          SubBase.run!(valid: false)
        }.to raise_error ActiveInteraction::InteractionInvalid
      end
    end
  end

  describe 'method_missing(attr_type, *args, &block)' do
    context 'it catches valid attr types' do
      class BoolTest < described_class
        boolean :test

        def execute; end
      end

      it 'adds an attr_reader for the method' do
        expect(BoolTest.new).to respond_to :test
      end

      it 'adds an attr_writer for the method' do
        expect(BoolTest.new).to respond_to :test=
      end
    end

    context 'allows multiple methods to be defined' do
      class BoolTest < described_class
        boolean :test1, :test2

        def execute; end
      end

      it 'creates a attr_reader for both methods' do
        expect(BoolTest.new).to respond_to :test1
        expect(BoolTest.new).to respond_to :test2
      end

      it 'creates a attr_writer for both methods' do
        expect(BoolTest.new).to respond_to :test1
        expect(BoolTest.new).to respond_to :test2
      end
    end

    context 'does not stop other missing methods from erroring out' do
      it 'throws a missing method error for non-attr types' do
        expect {
          class FooTest < described_class
            foo :test

            def execute; end
          end
        }.to raise_error NoMethodError
      end
    end
  end

  its(:new_record?) { should be_true  }
  its(:persisted?)  { should be_false }

  describe '#execute' do
    it 'throws a NotImplementedError' do
      expect { base.execute }.to raise_error NotImplementedError
    end

    context 'integration' do
      class TestInteraction < described_class
        boolean :b
        def execute; end
      end

      it 'raises an error with invalid option' do
        expect {
          TestInteraction.run!(b: 0)
        }.to raise_error ActiveInteraction::InteractionInvalid
      end

      it 'does not raise an error with valid option' do
        expect { TestInteraction.run!(b: true) }.to_not raise_error
      end

      it 'requires required options' do
        expect(TestInteraction.run b: nil).to_not be_valid
      end
    end
  end
end
