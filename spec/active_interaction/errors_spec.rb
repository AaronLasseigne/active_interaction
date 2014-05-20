# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Errors do
  let(:klass) do
    Class.new do
      include ActiveInteraction::ActiveModelable

      attr_reader :attribute

      def self.name
        @name ||= SecureRandom.hex
      end
    end
  end

  subject(:errors) { described_class.new(klass.new) }

  describe '#add_sym' do
    it 'defaults to :invalid' do
      errors.add_sym(:attribute)
      expect(errors.symbolic[:attribute]).to eql [:invalid]
    end

    it 'adds a symbol' do
      errors.add_sym(:attribute, :symbol)
      expect(errors.symbolic[:attribute]).to eql [:symbol]
    end

    it 'accepts a message' do
      errors.add_sym(:attribute, :symbol, 'message')
      expect(errors.symbolic[:attribute]).to eql [:symbol]
    end

    it 'accepts a message and options' do
      errors.add_sym(:attribute, :symbol, 'message', key: :value)
      expect(errors.symbolic[:attribute]).to eql [:symbol]
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
      expect(errors.symbolic).to eql({})
    end
  end

  describe '#initialize_dup' do
    let(:errors_dup) { errors.dup }

    before do
      errors.add_sym(:attribute)
    end

    it 'dups symbolic' do
      expect(errors_dup.symbolic).to eql errors.symbolic
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

  describe '#merge!' do
    let(:other) { described_class.new(klass.new) }

    context 'with an error' do
      before do
        other.add(:attribute)
      end

      it 'adds the error' do
        errors.merge!(other)
        expect(errors.messages[:attribute]).to eql ['is invalid']
      end

      it 'does not add duplicate errors' do
        other.add(:attribute)
        errors.merge!(other)
        expect(errors.messages[:attribute]).to eql ['is invalid']
      end
    end

    context 'with a symbolic error' do
      before do
        other.add_sym(:attribute)
      end

      it 'adds the error' do
        errors.merge!(other)
        expect(errors.symbolic[:attribute]).to eql [:invalid]
      end
    end

    context 'with an interpolated symbolic error' do
      before do
        I18n.backend.store_translations('en',
          activemodel: {
            errors: {
              models: {
                klass.name => {
                  attributes: {
                    attribute: {
                      invalid_type: 'is not a valid %{type}'
                    }
                  }
                }
              }
            }
          }
        )

        other.add_sym(:attribute, :invalid_type, type: nil)
      end

      it 'does not raise an error' do
        expect { errors.merge!(other) }.to_not raise_error
      end
    end

    context 'with ActiveModel errors' do
      let(:other) { ActiveModel::Errors.new(klass.new) }

      it 'does not raise an error' do
        expect { errors.merge!(other) }.to_not raise_error
      end
    end
  end
end
