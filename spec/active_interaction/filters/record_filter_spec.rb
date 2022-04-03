require 'spec_helper'

class RecordThing
  def self.find(_)
    raise 'error'
  end

  def self.finder(_)
    @finder ||= new
  end

  def self.finds_nil(_)
    nil
  end

  def self.finds_bad_value(_)
    Object.new
  end
end

class RecordThings; end # rubocop:disable Lint/EmptyClass
BackupRecordThing = RecordThing

describe ActiveInteraction::RecordFilter, :filter do
  include_context 'filters'
  before do
    options[:class] = RecordThing
  end

  it_behaves_like 'a filter'

  describe '#process' do
    let(:value) { RecordThing.new }
    let(:result) { filter.process(value, nil) }

    context 'with an instance of the class' do
      it 'returns the instance' do
        expect(result.value).to eql value
      end

      context 'with an instance that is a subclass' do
        let(:subclass) { Class.new(RecordThing) }
        let(:value) { subclass.new }

        it 'returns the instance' do
          expect(result.value).to eql value
        end
      end

      it 'handles reconstantizing' do
        expect(result.value).to eql value

        Object.send(:remove_const, :RecordThing)
        RecordThing = BackupRecordThing # rubocop:disable Lint/ConstantDefinitionInBlock
        value = RecordThing.new

        expect(filter.process(value, nil).value).to eql value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :RecordThing)
        RecordThing = BackupRecordThing # rubocop:disable Lint/ConstantDefinitionInBlock
        class SubRecordThing < RecordThing; end # rubocop:disable Lint/ConstantDefinitionInBlock
        value = SubRecordThing.new

        expect(filter.process(value, nil).value).to eql value
      end

      context 'without the class available' do
        before { Object.send(:remove_const, :RecordThing) }

        after { RecordThing = BackupRecordThing } # rubocop:disable Lint/ConstantDefinitionInBlock

        it 'does not raise an error on initialization' do
          expect { filter }.to_not raise_error
        end
      end
    end

    context 'with class as a superclass' do
      before do
        options[:class] = RecordThing.superclass
      end

      it 'returns the instance' do
        expect(result.value).to eql value
      end
    end

    context 'with class as a String' do
      before do
        options[:class] = RecordThing.name
      end

      it 'returns the instance' do
        expect(result.value).to eql value
      end
    end

    context 'with a plural class' do
      let(:value) { RecordThings.new }

      before { options[:class] = RecordThings }

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

    context 'with a value that does not match the class' do
      let(:value) { 1 }

      it 'calls the default finder' do
        allow(RecordThing).to receive(:find)
        result
        expect(RecordThing).to have_received(:find).with(value)
      end

      context 'with a custom finder' do
        before do
          options[:finder] = :finder
        end

        it 'calls the custom finder' do
          allow(RecordThing).to receive(:finder)
          result
          expect(RecordThing).to have_received(:finder).with(value)
        end
      end

      context 'that returns a nil' do
        let(:value) { 1 }

        before do
          options[:default] = RecordThing.new
          options[:finder] = :finds_nil
        end

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end
      end

      context 'that returns an invalid value' do
        let(:value) { 1 }

        before do
          options[:finder] = :finds_bad_value
        end

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end
      end
    end

    context 'with a blank String' do
      let(:value) { ' ' }

      context 'optional' do
        include_context 'optional'

        it 'returns the default' do
          expect(filter.process(value, nil).value).to eql options[:default]
        end
      end

      context 'required' do
        include_context 'required'

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::MissingValueError
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
