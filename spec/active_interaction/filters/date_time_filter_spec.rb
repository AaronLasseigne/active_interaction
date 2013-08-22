require 'spec_helper'

shared_examples_for 'valid datetime values' do |method, error|
  context 'with a DateTime' do
    let(:value) { DateTime.now }

    it 'returns the DateTime' do
      expect(send(method)).to eql value
    end
  end

  context 'with a valid String' do
    let(:value) { '2001-01-01T01:01:01+01:01' }

    it 'parses the String' do
      expect(send(method)).to eql DateTime.parse(value)
    end

    context 'with options[:format]' do
      let(:value) { '01010101012001' }

      before { options.merge!(format: '%S%M%H%m%d%Y') }

      it 'parses the String' do
        expect(send(method)).to eql DateTime.strptime(value, options[:format])
      end
    end
  end

  context 'with an invalid String' do
    let(:value) { 'not a valid DateTine' }

    it 'raises an error' do
      expect { send(method) }.to raise_error error
    end

    context 'with options[:format]' do
      before { options.merge!(format: '%S%M%H%m%d%Y') }

      it 'raises an error' do
        expect { send(method) }.to raise_error error
      end
    end
  end
end

describe ActiveInteraction::DateTimeFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid datetime values', :prepare, ActiveInteraction::InvalidValue
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid datetime values', :default, ActiveInteraction::InvalidDefaultValue
  end
end
