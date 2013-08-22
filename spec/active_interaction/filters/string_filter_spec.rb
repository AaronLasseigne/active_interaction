require 'spec_helper'

shared_examples_for 'valid string values' do |method|
  context 'with a String' do
    let(:value) { SecureRandom.hex }

    it 'returns the String' do
      expect(send(method)).to eql value
    end
  end

  context 'with a strippable String' do
    let(:value) { " #{SecureRandom.hex} " }

    it 'returns the stripped String' do
      expect(send(method)).to eql value.strip
    end

    context 'with options[:strip] as false' do
      before { options.merge!(strip: false) }

      it 'returns the String' do
        expect(send(method)).to eql value
      end
    end
  end
end

describe ActiveInteraction::StringFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid string values', :prepare
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid string values', :default
  end
end
