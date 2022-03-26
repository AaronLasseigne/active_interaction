require 'spec_helper'
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

describe ActiveInteraction::Errors do
  subject(:errors) { described_class.new(klass.new) }

  let(:klass) do
    Class.new do
      include ActiveInteraction::ActiveModelable

      attr_reader :attribute

      def self.name
        @name ||= SecureRandom.hex
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
      context 'that is a symbol' do
        before do
          other.add(:attribute)
        end

        it 'adds the error' do
          errors.merge!(other)
          expect(errors.details[:attribute]).to eql [{ error: :invalid }]
        end
      end

      context 'that is a symbol on base' do
        before do
          other.add(:base)
        end

        it 'adds the error' do
          errors.merge!(other)
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
          expect(errors.details[:base]).to eql [{ error: message }]
        end
      end

      context 'that uses the :message option' do
        let(:message) { SecureRandom.hex }
        let(:error_name) { :some_error }

        before do
          other.add(:base, error_name, message: message)
        end

        it 'adds the error' do
          errors.merge!(other)
          expect(errors.details[:base]).to eql [{ error: error_name }]
          expect(errors.messages[:base]).to eql [message]
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
                      invalid_type: 'is not a valid %<type>s'
                    }
                  }
                }
              }
            }
          }
        )

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

      it 'merges messages' do
        message = SecureRandom.hex
        other.add(:base, message)
        errors.merge!(other)
        expect(errors.messages[:base]).to include message
      end
    end

    context 'with nested errors' do
      let(:a_klass) do
        Class.new(ActiveRecord::Base) do
          has_one :b
          accepts_nested_attributes_for :b
        end
      end
      let(:a) { A.create(b_attributes: { name: nil }) }
      let(:b_klass) do
        Class.new(ActiveRecord::Base) do
          belongs_to :a

          validates :name, presence: true
        end
      end

      before do
        # suppress create_table output
        allow($stdout).to receive(:puts)
        ActiveRecord::Schema.define do
          create_table(:as)
          create_table(:bs) do |t|
            t.column :a_id, :integer
            t.column :name, :string
          end
        end

        stub_const('A', a_klass)
        stub_const('B', b_klass)
      end

      it 'merges the nested errors' do
        a.valid?
        expect(a.errors.messages).to eq('b.name': ["can't be blank"])
        expect(a.errors.size).to be 1
        expect { errors.merge!(a.errors) }.to_not raise_error
        expect(errors.size).to be 1
      end
    end
  end
end
