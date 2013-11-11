require 'spec_helper'

shared_examples_for 'valid values' do |method, error|
  context 'with a Float' do
    let(:value) { rand }

    it 'returns the Float' do
      expect(send(method)).to eql value
    end
  end

  context 'with an Integer' do
    let(:value) { rand(1 << 16) }

    it 'converts the Integer' do
      expect(send(method)).to eql Float(value)
    end
  end

  context 'with a valid String' do
    let(:value) { rand.to_s }

    it 'converts the String' do
      expect(send(method)).to eql Float(value)
    end
  end

  context 'with an invalid String' do
    let(:value) { 'not a valid Float' }

    it 'raises an error' do
      expect { send(method) }.to raise_error error
    end
  end
end

describe ActiveInteraction::FloatFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid values', :prepare, ActiveInteraction::InvalidValue
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid values', :default, ActiveInteraction::InvalidDefaultValue
  end
end
