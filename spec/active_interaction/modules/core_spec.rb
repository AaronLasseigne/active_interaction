# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::Core do
  let(:klass) { Class.new { include ActiveInteraction::Core } }
  subject(:instance) { klass.new }

  describe '#desc' do
    let(:desc) { SecureRandom.hex }

    it 'returns nil' do
      expect(instance.desc).to be_nil
    end

    it 'returns the description' do
      expect(instance.desc(desc)).to eq desc
    end

    it 'saves the description' do
      instance.desc(desc)
      expect(instance.desc).to eq desc
    end
  end
end
