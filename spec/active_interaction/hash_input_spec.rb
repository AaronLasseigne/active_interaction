require 'spec_helper'

describe ActiveInteraction::HashInput do
  subject(:input) do
    described_class.new(filter,
      value: value,
      error: error,
      children: children
    )
  end

  let(:filter) do
    ActiveInteraction::HashFilter.new(:h, &block)
  end
  let(:block) { proc { integer :i } }
  let(:value) { nil }
  let(:error) { nil }
  let(:children) { {} }

  describe '#errors' do
    context 'with no errors' do
      it 'returns an empty array' do
        expect(input.errors).to be_empty
      end
    end

    context 'with an error on the hash' do
      let(:error) { ActiveInteraction::Filter::Error.new(filter, :invalid_type) }

      it 'returns one error in the array' do
        expect(input.errors.size).to be 1

        error = input.errors.first
        expect(error.name).to be filter.name
        expect(error.type).to be :invalid_type
      end
    end

    context 'with children with errors' do
      let(:child_i) do
        filter = ActiveInteraction::IntegerFilter.new(:i)
        ActiveInteraction::Input.new(filter,
          value: nil,
          error: ActiveInteraction::Filter::Error.new(filter, :missing)
        )
      end
      let(:children) { { i: child_i } }

      it 'returns the error' do
        expect(input.errors.size).to be 1

        error = input.errors.first
        expect(error.name).to be :"#{filter.name}.i"
        expect(error.type).to be :missing
      end
    end
  end
end
