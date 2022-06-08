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
        allow(filter).to receive(:process).and_return(ActiveInteraction::Input.new(value: 1))
      end

      it 'returns no errors' do
        expect(result).to eql []
      end
    end

    context 'filter returns with errors' do
      before do
        allow(filter).to receive(:process).and_return(ActiveInteraction::Input.new(error: exception))
      end

      context 'InvalidValueError' do
        let(:filter) { ActiveInteraction::ArrayFilter.new(:name, [1.0, 'a']) { float } }

        context 'when the error has no index' do
          let(:exception) { ActiveInteraction::InvalidValueError.new }

          it 'returns an :invalid_type error' do
            type = I18n.translate(
              "#{ActiveInteraction::Base.i18n_scope}.types.#{filter.class.slug}"
            )

            expect(result).to eql [[filter.name, :invalid_type, { type: type }]]
          end
        end

        context 'when the error does not use an index' do
          let(:exception) do
            ActiveInteraction::InvalidValueError.new.tap { |e| e.index = 1 }
          end

          it 'returns an :invalid_type error' do
            type = I18n.translate(
              "#{ActiveInteraction::Base.i18n_scope}.types.#{filter.class.slug}"
            )

            expect(result).to eql [[filter.name, :invalid_type, { type: type }]]
          end
        end

        context 'when the error uses an index' do
          let(:exception) do
            ActiveInteraction::InvalidValueError.new(index_error: true).tap { |e| e.index = 1 }
          end

          it 'returns an :invalid_type error' do
            type = I18n.translate(
              "#{ActiveInteraction::Base.i18n_scope}.types.#{filter.class.slug}"
            )

            expect(result).to eql [[:"#{filter.name}[1]", :invalid_type, { type: type }]]
          end
        end
      end

      context 'MissingValueError' do
        let(:exception) { ActiveInteraction::MissingValueError.new }

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
            { name: name.inspect, value: value.inspect }
          ]]
        end
      end
    end
  end
end
