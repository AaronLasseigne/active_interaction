# coding: utf-8

require 'spec_helper'

InteractionWithFilter = Class.new(TestInteraction) do
  float :thing
end

describe ActiveInteraction::ActiveRecordable do
  include_context 'interactions'

  describe '#column_for_attribute(name)' do
    let(:described_class) { InteractionWithFilter }
    let(:column) { outcome.column_for_attribute(name) }

    context 'name is not an input name' do
      let(:name) { SecureRandom.hex }

      it 'returns nil if the attribute cannot be found' do
        expect(column).to be_nil
      end
    end

    context 'name is an input name' do
      let(:name) { described_class.filters.keys.first }

      it 'returns a FilterColumn' do
        expect(column).to be_a ActiveInteraction::FilterColumn
      end

      it 'returns a FilterColumn of type boolean' do
        expect(column.type).to eql :float
      end
    end
  end
end
