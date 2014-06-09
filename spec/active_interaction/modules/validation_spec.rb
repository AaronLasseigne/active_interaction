# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Validation do
  describe '.validate(filters, inputs)' do
    let(:inputs) { {} }
    let(:filter) { ActiveInteraction::Filter.new(:name, {}) }
    let(:filters) { { filter.name => filter } }
    let(:result) { described_class.validate(filters, inputs) }

    context 'no filters are given' do
      let(:filters) { {} }

      it 'returns no errors' do
        expect(result).to eql []
      end
    end

    context 'filter.cast returns a value' do
      let(:inputs) { { name: 1 } }

      before do
        allow(filter).to receive(:cast).and_return(1)
      end

      it 'returns no errors' do
        expect(result).to eql []
      end
    end

    context 'filter throws' do
      before do
        allow(filter).to receive(:cast).and_raise(exception)
      end

      context 'InvalidValueError' do
        let(:exception) { ActiveInteraction::InvalidValueError }
        let(:filter) { ActiveInteraction::FloatFilter.new(:name, {}) }

        it 'returns an :invalid_type error' do
          type = I18n.translate(
            "#{ActiveInteraction::Base.i18n_scope}.types.#{filter.class.slug}")

          expect(result).to eql [[filter.name, :invalid_type, nil, type: type]]
        end
      end

      context 'MissingValueError' do
        let(:exception) { ActiveInteraction::MissingValueError }

        it 'returns a :missing error' do
          expect(result).to eql [[filter.name, :missing]]
        end
      end

      context 'InvalidNestedValueError' do
        let(:exception) do
          ActiveInteraction::InvalidNestedValueError.new(name, value)
        end
        let(:name) { SecureRandom.hex.to_sym }
        let(:value) { double }

        it 'returns an :invalid_nested error' do
          expect(result).to eql [[
            filter.name,
            :invalid_nested,
            nil,
            { name: name.inspect, value: value.inspect }
          ]]
        end
      end
    end
  end
end
