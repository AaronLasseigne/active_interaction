require 'spec_helper'

# TODO: Check for invalid default.

shared_examples_for 'valid hash values' do |method, error|
  context 'with a Hash' do
    let(:value) { {} }

    it 'returns the Hash' do
      expect(send(method)).to eql value
    end
  end

  context 'with a block' do
    let(:block) { Proc.new { hash :a } }

    context 'with a Hash containing a Hash' do
      let(:value) { { a: {} } }

      it 'returns the Hash' do
        expect(send(method)).to eql value
      end
    end

    context 'with a Hash containing anything else' do
      let(:value) { { a: Object.new } }

      it 'raises an error' do
        expect {
          send(method)
        }.to raise_error error
      end
    end
  end

  context 'with a block with multiple filters' do
    let(:block) { Proc.new { hash :a; hash :b } }

    context 'with a Hash containing Hashes' do
      let(:value) { { a: {}, b: {} } }

      it 'returns the Hash' do
        expect(send(method)).to eql value
      end
    end
  end

  context 'with a nested block' do
    let(:block) { Proc.new { hash :a do; hash :b end } }
    let(:value) { { a: { b: {} } } }

    it 'returns the Hash' do
      expect(send(method)).to eql value
    end
  end
end

describe ActiveInteraction::HashFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid hash values', :prepare, ActiveInteraction::InvalidNestedValue
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid hash values', :default, ActiveInteraction::InvalidDefaultValue
  end
end
