require 'spec_helper'

describe ActiveInteraction::Errors do
  let(:klass) do
    Class.new do
      include ActiveModel::Model

      attr_reader :attribute

      def self.name
        SecureRandom.hex
      end
    end
  end

  subject(:errors) { described_class.new(klass.new) }

  describe '#add_sym' do
    it 'defaults to :invalid' do
      errors.add_sym(:attribute)
      expect(errors.symbolic).to eq(attribute: [:invalid])
    end

    it 'adds a symbol' do
      errors.add_sym(:attribute, :symbol)
      expect(errors.symbolic).to eq(attribute: [:symbol])
    end

    it 'accepts a message' do
      errors.add_sym(:attribute, :symbol, 'message')
      expect(errors.symbolic).to eq(attribute: [:symbol])
    end

    it 'accepts a message and options' do
      errors.add_sym(:attribute, :symbol, 'message', key: :value)
      expect(errors.symbolic).to eq(attribute: [:symbol])
    end

    context 'calling #add' do
      before do
        allow(errors).to receive(:add)
      end

      it 'with the default' do
        errors.add_sym(:attribute)
        expect(errors).to have_received(:add).once
          .with(:attribute, :invalid, {})
      end

      it 'with a symbol' do
        errors.add_sym(:attribute, :symbol)
        expect(errors).to have_received(:add).once
          .with(:attribute, :symbol, {})
      end

      it 'with a symbol and message' do
        errors.add_sym(:attribute, :symbol, 'message')
        expect(errors).to have_received(:add).once
          .with(:attribute, 'message', {})
      end

      it 'with a symbol, message and options' do
        errors.add_sym(:attribute, :symbol, 'message', key: :value)
        expect(errors).to have_received(:add).once
          .with(:attribute, 'message', key: :value)
      end
    end
  end

  describe '#initialize' do
    it 'sets symbolic to an empty hash' do
      expect(errors.symbolic).to eq({})
    end
  end

  describe '#initialize_dup' do
    let(:errors_dup) { errors.dup }

    before do
      errors.add_sym(:attribute)
    end

    it 'dups symbolic' do
      expect(errors_dup.symbolic).to eq errors.symbolic
      expect(errors_dup.symbolic).to_not equal errors.symbolic
    end
  end

  describe '#clear' do
    before do
      errors.add_sym(:attribute)
    end

    it 'clears symbolic' do
      errors.clear
      expect(errors.symbolic).to be_empty
    end
  end
end
