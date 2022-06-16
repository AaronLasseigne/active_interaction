require 'spec_helper'

describe ActiveInteraction::ArrayInput do
  subject(:input) do
    described_class.new(filter,
      value: value,
      error: error,
      index_errors: index_errors,
      children: children
    )
  end

  let(:filter) do
    ActiveInteraction::ArrayFilter.new(:a) { integer }
  end
  let(:value) { nil }
  let(:error) { nil }
  let(:index_errors) { false }
  let(:children) { [] }

  describe '#errors' do
    context 'with no errors' do
      it 'returns an empty array' do
        expect(input.errors).to be_empty
      end
    end

    context 'with an error on the array' do
      let(:error) { ActiveInteraction::Filter::Error.new(filter, :invalid_type) }

      it 'returns one error in the array (even with a child error)' do
        expect(input.errors.size).to be 1

        error = input.errors.first
        expect(error.name).to be filter.name
        expect(error.type).to be :invalid_type
      end
    end

    context 'with children with errors' do
      let(:child_filter) { ActiveInteraction::IntegerFilter.new(:i) }
      let(:child_error) { ActiveInteraction::Filter::Error.new(child_filter, :invalid_type) }
      let(:child1) { ActiveInteraction::Input.new(child_filter, value: 'a', error: child_error) }
      let(:child2) { ActiveInteraction::Input.new(child_filter, value: 'b', error: child_error) }
      let(:children) { [child1, child2] }

      context 'with an error on the array' do
        let(:error) { ActiveInteraction::Filter::Error.new(filter, :invalid_type) }

        it 'returns one error in the array' do
          expect(input.errors.size).to be 1

          error = input.errors.first
          expect(error.name).to be filter.name
          expect(error.type).to be :invalid_type
        end
      end

      context 'without :index_errors' do
        it 'promotes the first child error and returns it in the array' do
          expect(input.errors.size).to be 1

          error = input.errors.first
          expect(error.name).to be filter.name
          expect(error.type).to be :invalid_type
        end
      end

      context 'with :index_errors' do
        let(:index_errors) { true }

        it 'lists all child errors in the array' do
          expect(input.errors.size).to be 2

          input.errors.each_with_index do |error, i|
            expect(error.name).to be :"#{filter.name}[#{i}]"
            expect(error.type).to be :invalid_type
          end
        end
      end
    end
  end
end
