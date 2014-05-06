# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::UUIDFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    let(:result) { filter.cast(value) }

    context 'with valid input' do
      context 'with UUID as a String' do
        let(:value) { SecureRandom.uuid }

        it 'returns the UUID' do
          expect(result).to eql value
        end
      end

      context 'with UUID as a Symbol' do
        let(:value) { SecureRandom.uuid.to_sym }

        it 'returns the UUID as a String' do
          expect(result).to eql value.to_s
        end
      end
    end

    context 'with invalid input' do
      context "with invalid string" do
        let(:value) { SecureRandom.uuid + "a" }

        it 'returns the stripped string' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end

      context "with integer" do
        let(:value) { 123 }

        it 'returns the stripped string' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end

      context "with nil" do
        let(:value) { nil }

        it 'returns the stripped string' do
          expect do
            result
          end.to raise_error ActiveInteraction::MissingValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
