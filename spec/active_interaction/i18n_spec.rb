require 'spec_helper'

describe ActiveInteraction do
  context 'I18n.load_path' do
    it 'contains localization file paths' do
      expect(I18n.load_path)
        .to include a_string_ending_with('active_interaction/locale/en.yml')
    end
  end
end

I18nInteraction = Class.new(TestInteraction) do
  hash :a do
    hash :x
  end
end

TYPES = ActiveInteraction::Filter
  .const_get(:CLASSES)
  .keys
  .map(&:to_s)

describe I18nInteraction do
  include_context 'interactions'

  shared_examples 'translation' do |locale|
    around do |example|
      old_locale = I18n.locale
      I18n.locale = locale

      example.run

      I18n.locale = old_locale
    end

    context 'types' do
      TYPES.each do |type|
        it "has a translation for #{type}" do
          key = "#{described_class.i18n_scope}.types.#{type}"
          expect { I18n.translate(key, raise: true) }.to_not raise_error
        end
      end
    end

    context 'error messages' do
      let(:translation) { I18n.translate(key, type: type, raise: true) }
      let(:type) { I18n.translate("#{described_class.i18n_scope}.types.hash") }

      shared_examples 'translations' do |key, value|
        context key.inspect do
          let(:key) { "#{described_class.i18n_scope}.errors.messages.#{key}" }

          before { inputs[:a] = value }

          it 'has a translation' do
            expect { translation }.to_not raise_error
          end

          it 'returns the translation' do
            expect(outcome.errors[:a]).to include translation
          end
        end
      end

      include_examples 'translations', :invalid_type, Object.new
      include_examples 'translations', :missing, nil
    end
  end

  context 'english' do
    include_examples 'translation', :en
  end

  context 'brazilian portuguese' do
    include_examples 'translation', :'pt-BR'
  end

  context 'french' do
    include_examples 'translation', :fr
  end

  context 'italian' do
    include_examples 'translation', :it
  end

  context 'hsilgne' do
    # This must appear before including the translation examples so that the
    # locale is available before it is assigned.
    around do |example|
      old_locals = I18n.config.available_locales
      I18n.config.available_locales += [:hsilgne]

      I18n.backend.store_translations('hsilgne',
        active_interaction: {
          errors: {
            messages: {
              invalid: 'is invalid'.reverse,
              invalid_type: "%<type>s} #{'is not a valid'.reverse}",
              missing: 'missing'.reverse
            }
          },
          types: TYPES.each_with_object({}) { |e, a| a[e] = e.reverse }
        }
      )

      example.run

      I18n.config.available_locales = old_locals
    end

    include_examples 'translation', :hsilgne
  end
end
