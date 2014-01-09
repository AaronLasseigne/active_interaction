# coding: utf-8

require 'spec_helper'
require 'test/unit/assertions'

shared_examples_for 'ActiveModel' do
  include ActiveModel::Lint::Tests
  include Test::Unit::Assertions

  let(:model) { subject }

  ActiveModel::Lint::Tests.public_instance_methods
    .grep(/\Atest/) { |m| example(m) { send(m) } }
end

describe ActiveInteraction::ActiveModelable do
  include_context 'concerns', ActiveInteraction::ActiveModelable

  it_behaves_like 'ActiveModel'

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
