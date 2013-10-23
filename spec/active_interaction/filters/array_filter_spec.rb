require 'spec_helper'

describe ActiveInteraction::ArrayFilter do
  include_context 'filters with blocks'
  it_behaves_like 'a filter with a block'

  context 'block evaluation' do
    context 'empty block' do
      it 'adds no filters' do
        expect(result.filters).to be_none
      end
    end

    context 'non-empty block' do
      let(:block) { Proc.new { array } }

      it 'adds filters' do
        expect(result.filters).to have(1).filter
      end

      context 'where the internal filter is passed a name' do
        let(:block) { Proc.new { array :a } }

        it 'adds filters' do
          expect { result.filters }.to raise_error ArgumentError
        end
      end

      context 'where two filters are provided' do
        let(:block) { Proc.new { array; array } }

        it 'only allows one' do
          expect { result.filters }.to raise_error ArgumentError
        end
      end
    end
  end
end
