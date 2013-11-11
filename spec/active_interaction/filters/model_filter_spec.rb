require 'spec_helper'

TestModel = Class.new

shared_examples_for 'valid model values' do |method|
  shared_examples 'type checking' do
    context 'with the right class' do
      let(:value) { TestModel.new }

      it 'returns the instance' do
        expect(send(method)).to eql value
      end
    end
  end

  context 'with options[:class] as a Class' do
    include_examples 'type checking'
  end

  context 'with options[:class] as a valid String' do
    include_examples 'type checking'

    before { options.merge!(class: options[:class].to_s) }
  end

  context 'with options[:class] as an invalid String' do
    before { options.merge!(class: 'not a valid Class') }

    it 'raises an error' do
      expect { send(method) }.to raise_error NameError
    end
  end
end

describe ActiveInteraction::ModelFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before { options.merge!(class: TestModel) }

  describe '.prepare(key, value, options = {}, &block)' do
    include_examples 'valid model values', :prepare
  end

  describe '.default(key, value, options = {}, &block)' do
    include_examples 'valid model values', :default
  end
end
