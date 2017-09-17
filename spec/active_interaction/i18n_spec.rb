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

describe I18nInteraction do
  include_context 'interactions'

  TYPES = ActiveInteraction::Filter
    .const_get(:CLASSES)
    .map { |slug, _| slug.to_s }

  shared_examples 'translation' do |locale|
    before do
      @locale = I18n.locale
      I18n.locale = locale
    end

    after { I18n.locale = @locale }

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
    before do
      # This must appear before including the translation examples so that the
      # locale is available before it is assigned.
      locale = :hsilgne
      unless I18n.locale_available?(locale)
        I18n.config.available_locales = I18n.config.available_locales + [locale]
      end
    end

    include_examples 'translation', :hsilgne

    before do
      I18n.backend.store_translations('hsilgne',
        active_interaction: {
          errors: {
            messages: {
              invalid: 'is invalid'.reverse,
              invalid_type: "%{type} #{'is not a valid'.reverse}",
              missing: 'missing'.reverse
            }
          },
          types: TYPES.each_with_object({}) { |e, a| a[e] = e.reverse }
        }
      )
    end
  end
end
