require 'spec_helper'

TestClass = Class.new

describe ActiveInteraction::ModelFilter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before { options.merge!(class: TestClass) }

  describe '.prepare(key, value, options = {}, &block)' do
    shared_examples 'typechecking' do
      context 'with the right class' do
        let(:value) { TestClass.new }

        it 'returns the instance' do
          expect(result).to eql value
        end
      end
    end

    context 'with options[:class] as a Class' do
      include_examples 'typechecking'
    end

    context 'with options[:class] as a valid String' do
      include_examples 'typechecking'

      before { options.merge!(class: options[:class].to_s) }
    end

    context 'with options[:class] as an invalid String' do
      before { options.merge!(class: 'not a valid Class') }

      it 'raises an error' do
        expect { result }.to raise_error NameError
      end
    end
  end
end
