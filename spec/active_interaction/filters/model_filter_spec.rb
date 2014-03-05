# coding: utf-8

require 'spec_helper'

class Model; end

describe ActiveInteraction::ModelFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before do
    options.merge!(class: Model)
  end

  describe '#cast' do
    let(:value) { Model.new }

    context 'with class as a Class' do
      it 'returns the instance' do
        expect(filter.cast(value)).to eq value
      end

      it 'handles reconstantizing' do
        expect(filter.cast(value)).to eq value

        Object.send(:remove_const, :Model)
        class Model; end
        value = Model.new

        expect(filter.cast(value)).to eq value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :Model)
        class Model; end
        class Submodel < Model; end
        value = Submodel.new

        expect(filter.cast(value)).to eq value
      end

      it 'does not overflow the stack' do
        klass = Class.new do
          def self.name
            Model.name
          end
        end

        expect do
          filter.cast(klass.new)
        end.to raise_error ActiveInteraction::InvalidValueError
      end
    end

    context 'with class as a superclass' do
      before do
        options.merge!(class: Model.superclass)
      end

      it 'returns the instance' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with class as a String' do
      before do
        options.merge!(class: Model.name)
      end

      it 'returns the instance' do
        expect(filter.cast(value)).to eq value
      end
    end

    context 'with class as an invalid String' do
      before do
        options.merge!(class: 'invalid')
      end

      it 'raises an error' do
        expect do
          filter.cast(value)
        end.to raise_error ActiveInteraction::InvalidClassError
      end
    end
  end
end
