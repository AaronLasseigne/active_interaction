require 'spec_helper'

describe ActiveInteraction::Runnable do
  let(:klass) { Class.new { include ActiveInteraction::Runnable } }

  subject(:instance) { klass.new }

  describe '.run' do
    it
  end

  describe '.run!' do
    it
  end

  describe '#errors' do
    it
  end

  describe '#execute' do
    it
  end

  describe '#result' do
    it
  end
end
