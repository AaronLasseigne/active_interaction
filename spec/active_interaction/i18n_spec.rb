require 'spec_helper'

describe 'I18n' do
  class I18nTest < ActiveInteraction::Base
    hash :thing do
      integer :i
    end

    def execute; end
  end

  context 'types' do
    before do
      I18n.locale = :en
    end

    [
      :array,
      :boolean,
      :date,
      :date_time,
      :file,
      :float,
      :hash,
      :integer,
      :model,
      :string,
      :time
    ].each do |type|
      it "has a value for #{type} in English" do
        expect(I18n.translate(:"active_interaction.types.#{type}")).to eq type.to_s.humanize.downcase
      end
    end
  end

  context 'model name' do
    let(:model_name) { 'Internationalization Test' }

    before do
      I18n.locale = :en

      I18n.backend.store_translations :en, active_interaction: {
        models: {
          i18n_test: {
            one: model_name,
            other: model_name + 's'
          }}}
    end

    it 'returns the translated version of the singular model name' do
      expect(I18nTest.model_name.human).to eq model_name
    end

    it 'returns the translated version of the plural model name' do
      expect(I18nTest.model_name.human(count: 2)).to eq model_name + 's'
    end
  end

  context 'attributes' do
    let(:attr_name) { 'Thing' }

    context 'default' do
      it 'returns a humanized version of the attribute name' do
        expect(I18nTest.human_attribute_name(:thing)).to eq attr_name
      end
    end

    context 'translated' do
      let(:attr_name) { 'Thing'.downcase.reverse.capitalize }

      before do
        I18n.locale = :reverse

        I18n.backend.store_translations :reverse, active_interaction: {
          attributes: {
            i18n_test: {
              thing: attr_name
            }}}
      end

      it 'returns a translated version of the attribute name' do
        expect(
          I18nTest.human_attribute_name(:thing)
        ).to eq attr_name
      end
    end
  end

  context 'validations' do
    context 'default' do
      before do
        I18n.locale = :en
      end

      context ':invalid_nested' do
        it 'returns "is invalid" in English' do
          expect(
            I18nTest.run(thing: {i: Object.new}).errors[:thing]
          ).to eq ['is invalid']
        end
      end

      context ':invalid' do
        it 'returns "is not a valid hash" in English' do
          expect(
            I18nTest.run(thing: Object.new).errors[:thing]
          ).to eq ['is not a valid hash']
        end
      end

      context ':missing' do
        it 'returns "is required" in English' do
          expect(
            I18nTest.run().errors[:thing]
          ).to eq ['is required']
        end
      end
    end

    context 'translated' do
      before do
        I18n.locale = :reverse

        I18n.backend.store_translations :reverse, active_interaction: {
          types: {
            hash: 'hash'.reverse
          },
          errors: {
            messages: {
              invalid_nested: 'is invalid'.reverse,
              invalid:        "%{type} #{'is not a valid'.reverse}",
              missing:        'is required'.reverse
            }}}
      end

      context ':invalid_nested' do
        it 'returns "is invalid" translated' do
          expect(
            I18nTest.run(thing: {i: Object.new}).errors[:thing]
          ).to eq ['is invalid'.reverse]
        end
      end

      context ':invalid' do
        it 'returns "is not a valid hash" translated' do
          expect(
            I18nTest.run(thing: Object.new).errors[:thing]
          ).to eq ['is not a valid hash'.reverse]
        end
      end

      context ':missing' do
        it 'returns "is required" translated' do
          expect(
            I18nTest.run().errors[:thing]
          ).to eq ['is required'.reverse]
        end
      end
    end
  end
end
