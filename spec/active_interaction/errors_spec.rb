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
      context 'that is a symbol' do
        before do
          other.add(:attribute)
        end

        it 'adds the error' do
          errors.merge!(other)

          expect(errors.messages[:attribute]).to eql ['is invalid']
          expect(errors.details[:attribute]).to eql [{ error: :invalid }]
        end

        it 'does not add duplicate errors' do
          other.add(:attribute)
          errors.merge!(other)

          expect(errors.messages[:attribute]).to eql ['is invalid']
          expect(errors.details[:attribute]).to eql [{ error: :invalid }]
        end

        it 'merges unmatched errors onto base' do
          other = described_class.new(Class.new(klass) do
            attr_reader :attribute_2
          end.new)
          other.add(:attribute_2)
          errors.merge!(other)

          error_msg = 'Attribute 2 is invalid'

          expect(errors.messages[:base]).to eql [error_msg]
          expect(errors.details[:base]).to eql [{ error: error_msg }]
        end
      end

      context 'that is a symbol on base' do
        before do
          other.add(:base)
        end

        it 'adds the error' do
          errors.merge!(other)

          expect(errors.messages[:base]).to eql ['is invalid']
          expect(errors.details[:base]).to eql [{ error: :invalid }]
        end
      end

      context 'that is a string' do
        let(:message) { SecureRandom.hex }

        before do
          other.add(:base, message)
        end

        it 'adds the error' do
          errors.merge!(other)

          expect(errors.messages[:base]).to eql [message]
          expect(errors.details[:base]).to eql [{ error: message }]
        end
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
                    },
                    attribute2: {
                      invalid_type: 'is not a valid %{type}'
                    }
                  }
                }
              }
            }
          }
        )
      end

      context 'on a shared attribute' do
        it 'does not raise an error' do
          other.add(:attribute, :invalid_type, type: nil)

          expect { errors.merge!(other) }.to_not raise_error
        end
      end

      context 'on an attribute moved to base' do
        it 'does not raise an error' do
          other_klass = Class.new do
            include ActiveInteraction::ActiveModelable

            attr_reader :attribute2

            def self.name
              @name ||= SecureRandom.hex
            end
          end
          other = described_class.new(other_klass.new)
          other.add(:attribute2, :invalid_type, type: nil)

          expect { errors.merge!(other) }.to_not raise_error
        end
      end
    end

    context 'with ActiveModel errors' do
      let(:other) { ActiveModel::Errors.new(klass.new) }

      it 'does not raise an error' do
        expect { errors.merge!(other) }.to_not raise_error
      end

      it 'merges messages' do
        message = SecureRandom.hex
        other.add(:base, message)
        errors.merge!(other)
        expect(errors.messages[:base]).to include message
      end
    end
  end
end
