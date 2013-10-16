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

  describe '#sym_add' do
    it do
      errors.sym_add(:attribute)
      expect(errors.symbolic).to eq({ attribute: [:invalid] })
    end

    it do
      errors.sym_add(:attribute, :symbol)
      expect(errors.symbolic).to eq({ attribute: [:symbol] })
    end

    it do
      errors.sym_add(:attribute, :symbol, 'message')
      expect(errors.symbolic).to eq({ attribute: [:symbol] })
    end

    it do
      errors.sym_add(:attribute, :symbol, 'message', { key: :value })
      expect(errors.symbolic).to eq({ attribute: [:symbol] })
    end

    context do
      before do
        allow(errors).to receive(:add)
      end

      it do
        errors.sym_add(:attribute)
        expect(errors).to have_received(:add).once.
          with(:attribute, :invalid, {})
      end

      it do
        errors.sym_add(:attribute, :symbol)
        expect(errors).to have_received(:add).once.
          with(:attribute, :symbol, {})
      end

      it do
        errors.sym_add(:attribute, :symbol, 'message')
        expect(errors).to have_received(:add).once.
          with(:attribute, 'message', {})
      end

      it do
        errors.sym_add(:attribute, :symbol, 'message', { key: :value })
        expect(errors).to have_received(:add).once.
          with(:attribute, 'message', { key: :value })
      end
    end
  end
end
