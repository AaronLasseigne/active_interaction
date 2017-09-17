require 'spec_helper'

describe ActiveInteraction::FilterColumn do
  let(:type) { :float }
  subject(:column) { described_class.intern(type) }

  describe '.intern(type)' do
    it 'returns the same object for each type' do
      expect(described_class.intern(type)).to equal column
    end

    it 'returns different objects for different types' do
      expect(described_class.intern(:integer)).to_not equal column
    end
  end

  describe '.new(type)' do
    it 'is private' do
      expect { described_class.new(type) }.to raise_error NoMethodError
    end
  end

  describe '#limit' do
    it 'returns nil' do
      expect(column.limit).to be_nil
    end
  end

  describe '#type' do
    it 'returns the type' do
      expect(column.type).to eql type
    end
  end

  describe '#number?' do
    let(:number?) { column.number? }

    context 'type is' do
      context ':integer' do
        let(:type) { :integer }

        it 'returns true' do
          expect(number?).to be_truthy
        end
      end

      context ':float' do
        let(:type) { :float }

        it 'returns true' do
          expect(number?).to be_truthy
        end
      end

      context 'anything else' do
        let(:type) { :string }

        it 'returns false' do
          expect(number?).to be_falsey
        end
      end
    end
  end

  describe '#text?' do
    let(:text?) { column.text? }

    context 'type is' do
      context ':string' do
        let(:type) { :string }

        it 'returns true' do
          expect(text?).to be_truthy
        end
      end

      context 'anything else' do
        let(:type) { :float }

        it 'returns false' do
          expect(text?).to be_falsey
        end
      end
    end
  end

  describe '#type' do
    let(:type) { :float }

    it 'returns the type' do
      expect(column.type).to eql type
    end
  end
end
