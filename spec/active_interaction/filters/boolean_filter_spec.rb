require 'spec_helper'

shared_examples_for 'valid boolean values' do |method|
  context 'with true' do
    let(:value) { true }

    it 'returns true' do
      expect(send(method)).to eql true
    end
  end

  context 'with false' do
    let(:value) { false }

    it 'returns false' do
      expect(send(method)).to eql false
    end
  end

  context 'with "1"' do
    let(:value) { '1' }

    it 'returns true' do
      expect(send(method)).to eql true
    end
  end

  context 'with "0"' do
    let(:value) { '0' }

    it 'returns false' do
      expect(send(method)).to eql false
    end
  end
end

describe ActiveInteraction::BooleanFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid boolean values', :prepare
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid boolean values', :default
  end
end
