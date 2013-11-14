require 'spec_helper'

describe ActiveInteraction::ActiveModel do
  subject(:model) do
    Class.new do
      include ActiveInteraction::ActiveModel
    end
  end

  describe '#new_record?' do
    it 'returns true' do
      expect(model.new).to be_new_record
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      expect(model.new).to_not be_persisted
    end
  end

  describe '.i18n_scope' do
    it 'returns the scope' do
      expect(model.i18n_scope).to eq :active_interaction
    end
  end

  describe '#i18n_scope' do
    it 'returns the scope' do
      expect(model.new.i18n_scope).to eq :active_interaction
    end
  end
end
