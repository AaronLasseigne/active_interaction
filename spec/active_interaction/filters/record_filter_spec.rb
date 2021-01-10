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
    ''
  end

  def self.passthrough(obj)
    obj
  end
end

class RecordThings; end # rubocop:disable Lint/EmptyClass
BackupRecordThing = RecordThing

describe ActiveInteraction::RecordFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  before do
    options[:class] = RecordThing
  end

  describe '#cast' do
    before do
      options[:finder] = :finder
    end

    let(:value) { RecordThing.new }
    let(:result) { filter.send(:cast, value, nil) }

    context 'with an instance of the class' do
      it 'returns the instance' do
        expect(result).to eql value
      end

      context 'with an instance that is a subclass' do
        let(:subclass) { Class.new(RecordThing) }
        let(:value) { subclass.new }

        it 'returns the instance' do
          expect(result).to eql value
        end
      end

      it 'handles reconstantizing' do
        expect(result).to eql value

        Object.send(:remove_const, :RecordThing)
        RecordThing = BackupRecordThing # rubocop:disable Lint/ConstantDefinitionInBlock
        value = RecordThing.new

        expect(filter.send(:cast, value, nil)).to eql value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :RecordThing)
        RecordThing = BackupRecordThing # rubocop:disable Lint/ConstantDefinitionInBlock
        class SubRecordThing < RecordThing; end # rubocop:disable Lint/ConstantDefinitionInBlock
        value = SubRecordThing.new

        expect(filter.send(:cast, value, nil)).to eql value
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
        expect(result).to eql value
      end
    end

    context 'with class as a String' do
      before do
        options[:class] = RecordThing.name
      end

      it 'returns the instance' do
        expect(result).to eql value
      end
    end

    context 'with a plural class' do
      let(:value) { RecordThings.new }

      before { options[:class] = RecordThings }

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

    context 'with a value that does not match the class' do
      let(:value) { '' }

      it 'calls the finder' do
        expect(result).to eql RecordThing.finder(value)
      end

      context 'with a custom finder' do
        it 'calls the custom finder' do
          expect(result).to eql RecordThing.finder(value)
        end
      end
    end
  end

  describe '#clean' do
    context 'with a value that does not match the class' do
      context 'that returns a nil' do
        let(:value) { '' }

        before do
          options[:default] = RecordThing.new
          options[:finder] = :finds_nil
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
          options[:finder] = :finds_bad_value
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
