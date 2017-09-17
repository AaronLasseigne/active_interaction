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
class RecordThings; end
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
    let(:result) { filter.cast(value, nil) }

    context 'with class as a Class' do
      it 'returns the instance' do
        expect(result).to eql value
      end

      it 'handles reconstantizing' do
        expect(result).to eql value

        Object.send(:remove_const, :RecordThing)
        RecordThing = BackupRecordThing
        value = RecordThing.new

        expect(filter.cast(value, nil)).to eql value
      end

      it 'handles reconstantizing subclasses' do
        filter

        Object.send(:remove_const, :RecordThing)
        RecordThing = BackupRecordThing
        class SubRecordThing < RecordThing; end
        value = SubRecordThing.new

        expect(filter.cast(value, nil)).to eql value
      end

      context 'without the class available' do
        before { Object.send(:remove_const, :RecordThing) }
        after { RecordThing = BackupRecordThing }

        it 'does not raise an error on initialization' do
          expect { filter }.to_not raise_error
        end
      end

      context 'with bidirectional class comparisons' do
        let(:case_equality) { false }
        let(:class_equality) { false }

        before do
          options[:finder] = :passthrough

          allow(RecordThing).to receive(:===).and_return(case_equality)
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
        end.to raise_error ActiveInteraction::InvalidClassError
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
