require 'spec_helper'

InteractionWithFloatFilter = Class.new(TestInteraction) do
  float :thing
end

describe ActiveInteraction::ActiveRecordable do
  include_context 'interactions'

  let(:described_class) { InteractionWithFloatFilter }

  describe '#column_for_attribute(name)' do
    let(:column) { outcome.column_for_attribute(name) }

    context 'name is not an input name' do
      let(:name) { SecureRandom.hex }

      it 'returns nil if the attribute cannot be found' do
        expect(column).to be_nil
      end
    end

    context 'name is an input name' do
      let(:name) { described_class.filters.keys.first }

      it 'returns a Filter::Column' do
        expect(column).to be_a ActiveInteraction::Filter::Column
      end

      it 'returns a Filter::Column of type boolean' do
        expect(column.type).to be :float
      end
    end
  end

  describe '#has_attribute?' do
    it 'returns true if the filter exists' do
      expect(outcome).to have_attribute(:thing)
    end

    it 'works with strings' do
      expect(outcome).to have_attribute('thing')
    end

    it 'returns false if the filter does not exist' do
      expect(outcome).to_not have_attribute(:not_a_filter)
    end
  end
end
