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
    let(:result) { filter.cast(value) }

    context 'with class as a Class' do
      it 'returns the instance' do
        expect(result).to eql value
      end

      it 'handles reconstantizing' do
        expect(result).to eql value

        Object.send(:remove_const, :Model)
        class Model; end
        value = Model.new

        expect(filter.cast(value)).to eql value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :Model)
        class Model; end
        class Submodel < Model; end
        value = Submodel.new

        expect(filter.cast(value)).to eql value
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

      context 'without the class available' do
        before { Object.send(:remove_const, :Model) }
        after { class Model; end }

        it 'does not raise an error on initialization' do
          expect { filter }.to_not raise_error
        end
      end

      context 'inheritance shenanigans' do
        let(:case_equality) { false }
        let(:class_equality) { false }
        let(:exact_equality) { false }

        before do
          allow(Model).to receive(:===).and_return(case_equality)
          allow(value).to receive(:instance_of?).and_return(exact_equality)
          allow(value).to receive(:is_a?).and_return(class_equality)
        end

        context 'without case or class or exact equality' do
          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with case equality' do
          let(:case_equality) { true }

          it 'returns the instance' do
            expect(result).to eql value
          end
        end

        context 'with class equality' do
          let(:class_equality) { true }

          it 'returns the instance' do
            expect(result).to eql value
          end
        end

        context 'with exact equality' do
          let(:exact_equality) { true }

          it 'returns the instance' do
            expect(result).to eql value
          end
        end
      end
    end

    context 'with class as a superclass' do
      before do
        options.merge!(class: Model.superclass)
      end

      it 'returns the instance' do
        expect(result).to eql value
      end
    end

    context 'with class as a String' do
      before do
        options.merge!(class: Model.name)
      end

      it 'returns the instance' do
        expect(result).to eql value
      end
    end

    context 'with class as an invalid String' do
      before do
        options.merge!(class: 'invalid')
      end

      it 'raises an error' do
        expect do
          result
        end.to raise_error ActiveInteraction::InvalidClassError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
