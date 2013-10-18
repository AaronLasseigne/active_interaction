require 'spec_helper'

TestModel = Class.new

describe ActiveInteraction::ModelCaster do
  include_context 'filters'
  it_behaves_like 'a filter'

  before { options.merge!(class: TestModel) }

  describe '.prepare(key, value, options = {}, &block)' do
    shared_examples 'type checking' do
      context 'with the right class' do
        let(:value) { TestModel.new }

        it 'returns the instance' do
          expect(result).to eql value
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
        expect { result }.to raise_error NameError
      end
    end
  end
end
