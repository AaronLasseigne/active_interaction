require 'spec_helper'

describe ActiveInteraction::HashFilter do
  include_context 'filters with blocks'
  it_behaves_like 'a filter with a block'

  context 'block evaluation' do
    context 'empty block' do
      it 'adds no filters' do
        expect(result.filters).to be_none
      end
    end

    context 'non-empty block' do
      let(:block) { Proc.new { hash :a, :b } }

      it 'adds filters' do
        expect(result.filters).to have(2).filters
      end
    end
  end
end
