require 'spec_helper'

class ObjectThing
  def self.converter(_)
    @converter ||= new
  end

  def self.converter_with_error(_)
    raise 'error'
  end
end

class ObjectThings; end # rubocop:disable Lint/EmptyClass
BackupObjectThing = ObjectThing

describe ActiveInteraction::ObjectFilter, :filter do
  include_context 'filters'
  before do
    options[:class] = ObjectThing
  end

  it_behaves_like 'a filter'

  describe '#process' do
    let(:value) { ObjectThing.new }
    let(:result) { filter.process(value, nil) }

    context 'with an instance of the class' do
      it 'returns the instance' do
        expect(result.value).to eql value
      end

      context 'with an instance that is a subclass' do
        let(:subclass) { Class.new(ObjectThing) }
        let(:value) { subclass.new }

        it 'returns the instance' do
          expect(result.value).to eql value
        end
      end

      it 'handles reconstantizing' do
        expect(result.value).to eql value

        Object.send(:remove_const, :ObjectThing)
        ObjectThing = BackupObjectThing # rubocop:disable Lint/ConstantDefinitionInBlock
        value = ObjectThing.new

        expect(filter.process(value, nil).value).to eql value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :ObjectThing)
        ObjectThing = BackupObjectThing # rubocop:disable Lint/ConstantDefinitionInBlock
        class SubObjectThing < ObjectThing; end # rubocop:disable Lint/ConstantDefinitionInBlock
        value = SubObjectThing.new

        expect(filter.process(value, nil).value).to eql value
      end

      context 'without the class available' do
        before { Object.send(:remove_const, :ObjectThing) }

        after { ObjectThing = BackupObjectThing } # rubocop:disable Lint/ConstantDefinitionInBlock

        it 'does not raise an error on initialization' do
          expect { filter }.to_not raise_error
        end
      end
    end

    context 'with class as a String' do
      before do
        options[:class] = ObjectThing.name
      end

      it 'returns the instance' do
        expect(result.value).to eql value
      end
    end

    context 'with a plural class' do
      let(:value) { ObjectThings.new }

      before { options[:class] = ObjectThings }

      it 'returns the instance' do
        expect(result.value).to eql value
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
          expect(result.value).to eql ObjectThing.converter(value)
        end
      end

      context 'that is a proc' do
        before do
          options[:converter] = ->(x) { ObjectThing.converter(x) }
        end

        it 'gets called' do
          expect(result.value).to eql ObjectThing.converter(value)
        end
      end

      context 'with an object of the correct class' do
        let(:value) { ObjectThing.new }

        it 'does not call the converter' do
          allow(ObjectThing).to receive(:converter)
          result.value
          expect(ObjectThing).to_not have_received(:converter)
        end

        it 'returns the correct value' do
          expect(result.value).to eql value
        end
      end

      context 'with an object that is a subclass' do
        let(:subclass) { Class.new(ObjectThing) }
        let(:value) { subclass.new }

        it 'does not call the converter' do
          allow(subclass).to receive(:converter)
          result.value
          expect(subclass).to_not have_received(:converter)
        end

        it 'returns the correct value' do
          expect(result.value).to eql value
        end
      end

      context 'with a nil value' do
        let(:value) { nil }

        include_context 'optional'

        it 'returns nil' do
          allow(ObjectThing).to receive(:converter)
          result.value
          expect(ObjectThing).to_not have_received(:converter)
        end

        it 'returns the correct value' do
          expect(result.value).to eql value
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

        it 'indicates an error' do
          expect(
            result.error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end
      end

      context 'that returns a nil' do
        let(:value) { '' }

        before do
          options[:default] = ObjectThing.new
          options[:converter] = ->(_) {}
        end

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end
      end

      context 'that returns an invalid value' do
        let(:value) { '' }

        before do
          options[:converter] = ->(_) { 'invalid' }
        end

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to be :string
    end
  end
end
