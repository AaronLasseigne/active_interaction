require 'spec_helper'

shared_examples_for 'valid date values' do |method, error|
  context 'with a Date' do
    let(:value) { Date.today }

    it 'returns the Date' do
      expect(send(method)).to eql value
    end
  end

  context 'with a valid String' do
    let(:value) { '2001-01-01' }

    it 'parses the String' do
      expect(send(method)).to eql Date.parse(value)
    end

    context 'with options[:format]' do
      let(:value) { '01012001' }

      before { options.merge!(format: '%m%d%Y') }

      it 'parses the String' do
        expect(send(method)).to eql Date.strptime(value, options[:format])
      end
    end
  end

  context 'with an invalid String' do
    let(:value) { 'not a valid Date' }

    it 'raises an error' do
      expect { send(method) }.to raise_error error
    end

    context 'with options[:format]' do
      before { options.merge!(format: '%m%d%Y') }

      it 'raises an error' do
        expect { send(method) }.to raise_error error
      end
    end
  end
end

describe ActiveInteraction::DateFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid date values', :prepare, ActiveInteraction::InvalidValue
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid date values', :default, ActiveInteraction::InvalidDefaultValue
  end
end
