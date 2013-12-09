require 'spec_helper'

class I18nInteraction < ActiveInteraction::Base
  hash :a do
    hash :x
  end

  def execute; end
end

describe I18nInteraction do
  include_context 'interactions'

  TYPES = %w(
    array
    boolean
    date
    date_time
    file
    float
    hash
    integer
    model
    string
    time
  )

  shared_examples 'translation' do
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

      context ':invalid' do
        let(:key) { "#{described_class.i18n_scope}.errors.messages.invalid" }

        it 'has a translation' do
          expect { translation }.to_not raise_error
        end

        it 'returns the translation' do
          options.merge!(a: Object.new)
          expect(outcome.errors[:a]).to eq [translation]
        end
      end

      context ':missing' do
        let(:key) { "#{described_class.i18n_scope}.errors.messages.missing" }

        it 'has a translation' do
          expect { translation }.to_not raise_error
        end

        it 'returns the translation' do
          expect(outcome.errors[:a]).to eq [translation]
        end
      end
    end
  end

  context 'english' do
    include_examples 'translation'

    before do
      I18n.locale = :en
    end
  end

  context 'hsilgne' do
    include_examples 'translation'

    before do
      I18n.backend.store_translations('hsilgne', active_interaction: {
        errors: { messages: {
          invalid: "%{type} #{'invalid'.reverse}",
          invalid_nested: 'invalid_nested'.reverse,
          missing: 'missing'.reverse
        } },
        types: TYPES.reduce({}) { |a, e| a[e] = e.reverse; a }
      })

      I18n.locale = 'hsilgne'
    end
  end
end
