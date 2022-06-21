require 'spec_helper'

describe ActiveInteraction::Validation do
  describe '.validate(context, filters, inputs)' do
    let(:inputs) { {} }
    let(:filter) { ActiveInteraction::Filter.new(:name, {}) }
    let(:interaction) do
      name = filter.name
      klass = Class.new(ActiveInteraction::Base) { attr_writer(name) }
      klass.filters[name] = filter
      klass.new
    end
    let(:result) do
      described_class.validate(interaction, interaction.class.filters, inputs)
    end

    context 'no filters are given' do
      let(:interaction) { Class.new(ActiveInteraction::Base).new }

      it 'returns no errors' do
        expect(result).to eql []
      end
    end

    context 'filter returns no errors' do
      let(:inputs) { { name: 1 } }

      before do
        allow(filter).to receive(:process).and_return(ActiveInteraction::Input.new(filter, value: 1))
      end

      it 'returns no errors' do
        expect(result).to eql []
      end
    end

    context 'filter returns with errors' do
      before do
        allow(filter).to receive(:process).and_return(ActiveInteraction::Input.new(filter, error: exception))
      end

      context 'Filter::Error' do
        let(:filter) { ActiveInteraction::ArrayFilter.new(:name, [1.0, 'a']) { float } }

        let(:exception) { ActiveInteraction::Filter::Error.new(filter, :invalid_type) }

        it 'returns an :invalid_type error' do
          type = I18n.translate(
            "#{ActiveInteraction::Base.i18n_scope}.types.#{filter.class.slug}"
          )

          expect(result).to eql [[filter.name, :invalid_type, { type: type }]]
        end
      end
    end
  end
end
