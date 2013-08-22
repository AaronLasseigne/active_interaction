require 'spec_helper'

shared_examples_for 'valid integer values' do |method, error|
  context 'with an Integer' do
    let(:value) { rand(1 << 16) }

    it 'returns the Integer' do
      expect(send(method)).to eql value
    end
  end

  context 'with a valid String' do
    let(:value) { rand(1 << 16).to_s }

    it 'converts the String' do
      expect(send(method)).to eql Integer(value)
    end
  end

  context 'with an invalid String' do
    let(:value) { 'not a valid Integer' }

    it 'raises an error' do
      expect { send(method) }.to raise_error error
    end
  end
end

describe ActiveInteraction::IntegerFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid integer values', :prepare, ActiveInteraction::InvalidValue
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid integer values', :default, ActiveInteraction::InvalidDefaultValue
  end
end
