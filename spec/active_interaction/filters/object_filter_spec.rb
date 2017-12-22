require 'spec_helper'

class ObjectThing
  def self.converter(_)
    @converter ||= new
  end

  def self.converter_with_error(_)
    raise 'error'
  end
end
class ObjectThings; end
BackupObjectThing = ObjectThing

describe ActiveInteraction::ObjectFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before do
    options[:class] = ObjectThing
  end

  describe '#cast' do
    let(:value) { ObjectThing.new }
    let(:result) { filter.cast(value, nil) }

    context 'with class as a Class' do
      it 'returns the instance' do
        expect(result).to eql value
      end

      it 'handles reconstantizing' do
        expect(result).to eql value

        Object.send(:remove_const, :ObjectThing)
        ObjectThing = BackupObjectThing
        value = ObjectThing.new

        expect(filter.cast(value, nil)).to eql value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :ObjectThing)
        ObjectThing = BackupObjectThing
        class SubObjectThing < ObjectThing; end
        value = SubObjectThing.new

        expect(filter.cast(value, nil)).to eql value
      end

      context 'without the class available' do
        before { Object.send(:remove_const, :ObjectThing) }
        after { ObjectThing = BackupObjectThing }

        it 'does not raise an error on initialization' do
          expect { filter }.to_not raise_error
        end
      end

      context 'with bidirectional class comparisons' do
        let(:case_equality) { false }
        let(:class_equality) { false }

        before do
          allow(ObjectThing).to receive(:===).and_return(case_equality)
          allow(value).to receive(:is_a?).and_return(class_equality)
        end

        context 'without case or class equality' do
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
      end
    end

    context 'with class as a superclass' do
      before do
        options[:class] = ObjectThing.superclass
      end

      it 'returns the instance' do
        expect(result).to eql value
      end
    end

    context 'with class as a String' do
      before do
        options[:class] = ObjectThing.name
      end

      it 'returns the instance' do
        expect(result).to eql value
      end
    end

    context 'with a plural class' do
      let(:value) { ObjectThings.new }

      before { options[:class] = ObjectThings }

      it 'returns the instance' do
        expect(result).to eql value
      end
    end

    context 'with class as an invalid String' do
      before do
        options[:class] = 'invalid'
      end

      it 'raises an error' do
        expect do
          result
        end.to raise_error ActiveInteraction::InvalidNameError
      end
    end

    context 'with a converter' do
      let(:value) { '' }

      context 'that is a symbol' do
        before do
          options[:converter] = :converter
        end

        it 'calls the class method' do
          expect(result).to eql ObjectThing.converter(value)
        end
      end

      context 'that is a proc' do
        before do
          options[:converter] = ->(x) { ObjectThing.converter(x) }
        end

        it 'gets called' do
          expect(result).to eql ObjectThing.converter(value)
        end
      end

      context 'with a object of the correct class' do
        let(:value) { ObjectThing.new }

        it 'does not call the converter' do
          expect(ObjectThing).to_not receive(:converter)
          expect(result).to eql value
        end
      end

      context 'with a object is a subclass' do
        let(:subclass) { Class.new(ObjectThing) }
        let(:value) { subclass.new }

        it 'does not call the converter' do
          expect(subclass).to_not receive(:converter)
          expect(result).to eql value
        end
      end

      context 'with a nil value' do
        let(:value) { nil }
        include_context 'optional'

        it 'returns nil' do
          expect(ObjectThing).to_not receive(:converter)
          expect(result).to eql value
        end
      end

      context 'that is invalid' do
        before do
          options[:converter] = 'invalid converter'
        end

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidConverterError
        end
      end

      context 'that throws an error' do
        before do
          options[:converter] = :converter_with_error
        end

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end
  end

  describe '#clean' do
    context 'with a converter' do
      context 'that returns a nil' do
        let(:value) { '' }

        before do
          options[:default] = ObjectThing.new
          options[:converter] = ->(_) { nil }
        end

        it 'raises an error' do
          expect do
            filter.clean(value, nil)
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end

      context 'that returns an invalid value' do
        let(:value) { '' }

        before do
          options[:converter] = ->(_) { 'invalid' }
        end

        it 'raises an error' do
          expect do
            filter.clean(value, nil)
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
