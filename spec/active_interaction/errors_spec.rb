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

  context 'backports' do
    describe '#delete' do
      it 'deletes the detailed error' do
        errors.add(:attribute)
        errors.delete(:attribute)
        expect(errors.details).to_not have_key :attribute
      end
    end

    describe '#initialize_dup' do
      it 'duplicates the detailed errors' do
        errors.add(:attribute)
        other = errors.dup
        expect(other.details).to eql errors.details
        expect(other.details).to_not be errors.details
      end
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

    context 'with a detailed error' do
      before do
        other.add(:attribute)
      end

      it 'adds the error' do
        errors.merge!(other)
        expect(errors.details[:attribute]).to eql [{ error: :invalid }]
      end
    end

    context 'with an interpolated detailed error' do
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
          })

        other.add(:attribute, :invalid_type, type: nil)
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
