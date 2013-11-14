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
        expect {
          filter.cast(value)
        }.to raise_error ActiveInteraction::InvalidClassError
      end
    end
  end
end
