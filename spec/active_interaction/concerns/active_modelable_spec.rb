require 'spec_helper'

shared_examples_for 'ActiveModel' do
  it 'includes ActiveModel::Conversion' do
    expect(subject).to be_a_kind_of ActiveModel::Conversion
  end

  it 'includes ActiveModel::Validations' do
    expect(subject).to be_a_kind_of ActiveModel::Validations
  end

  it 'extends ActiveModel::Naming' do
    expect(subject.class).to be_a_kind_of ActiveModel::Naming
  end
end

describe ActiveInteraction::ActiveModelable do
  include_context 'concerns', ActiveInteraction::ActiveModelable

  it_behaves_like 'ActiveModel'

  describe '.i18n_scope' do
    it 'returns the scope' do
      expect(klass.i18n_scope).to eql :active_interaction
    end
  end

  describe '#i18n_scope' do
    it 'returns the scope' do
      expect(instance.i18n_scope).to eql :active_interaction
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
