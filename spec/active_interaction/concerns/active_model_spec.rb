# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::ActiveModel do
  let(:klass) { Class.new { include ActiveInteraction::ActiveModel } }
  subject(:instance) { klass.new }

  describe '.i18n_scope' do
    it 'returns the scope' do
      expect(klass.i18n_scope).to eq :active_interaction
    end
  end

  describe '#i18n_scope' do
    it 'returns the scope' do
      expect(instance.i18n_scope).to eq :active_interaction
    end
  end

  describe '#new_record?' do
    it 'returns true' do
      expect(instance).to be_new_record
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      expect(instance).to_not be_persisted
    end
  end
end
