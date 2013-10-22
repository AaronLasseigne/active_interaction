require 'spec_helper'

describe ActiveInteraction::HashCaster do
  include_context 'casters', ActiveInteraction::HashFilter
  it_behaves_like 'a caster', ActiveInteraction::HashFilter

  describe '.prepare(filter, value)' do
    context 'with a Hash' do
      let(:value) { {} }

      it 'returns the Hash' do
        expect(result).to eql value
      end
    end

    context 'with a block' do
      let(:block) { Proc.new { hash :a } }

      context 'with a Hash containing a Hash' do
        let(:value) { { a: {} } }

        it 'returns the Hash' do
          expect(result).to eql value
        end
      end

      context 'with a Hash containing anything else' do
        let(:value) { { a: Object.new } }

        it 'raises an error' do
          expect {
            result
          }.to raise_error ActiveInteraction::InvalidNestedValue
        end
      end
    end

    context 'with a block with multiple filters' do
      let(:block) { Proc.new { hash :a; hash :b } }

      context 'with a Hash containing Hashes' do
        let(:value) { { a: {}, b: {} } }

        it 'returns the Hash' do
          expect(result).to eql value
        end
      end
    end

    context 'with a nested block' do
      let(:block) { Proc.new { hash :a do; hash :b end } }
      let(:value) { { a: { b: {} } } }

      it 'returns the Hash' do
        expect(result).to eql value
      end
    end
  end
end
