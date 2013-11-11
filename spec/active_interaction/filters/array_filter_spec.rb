require 'spec_helper'

shared_examples_for 'valid array values' do |method, error|
  context 'with an Array' do
    let(:value) { [] }

    it 'returns the Array' do
      expect(send(method)).to eql value
    end
  end

  context 'with a block' do
    let(:block) { Proc.new { array } }

    context 'with an Array of Arrays' do
      let(:value) { [[]] }

      it 'returns the Array' do
        expect(send(method)).to eql value
      end
    end

    context 'with an Array of anything else' do
      let(:value) { [Object.new] }

      it 'raises an error' do
        expect {
          send(method)
        }.to raise_error error
      end
    end
  end

  context 'with a nested block' do
    let(:block) { Proc.new { array { array } } }
    let(:value) { [[[]]] }

    it 'returns the Array' do
      expect(send(method)).to eql value
    end
  end

  context 'with an invalid block' do
    let(:block) { Proc.new { array; array } }
    let(:value) { [] }

    it 'raises an error' do
      expect { send(method) }.to raise_error ArgumentError
    end
  end
end

describe ActiveInteraction::ArrayFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid array values', :prepare, ActiveInteraction::InvalidNestedValue
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid array values', :default, ActiveInteraction::InvalidDefaultValue
  end
end
