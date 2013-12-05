require 'spec_helper'

class ActiveInteraction::TestFilter < ActiveInteraction::Filter; end

describe ActiveInteraction::Filter, :filter do
  include_context 'filters'

  describe '.slug' do
    it 'raises an error' do
      expect do
        described_class.slug
      end.to raise_error ActiveInteraction::InvalidClassError
    end
  end

  context ActiveInteraction::TestFilter do
    it_behaves_like 'a filter'

    let(:described_class) { ActiveInteraction::TestFilter }
  end
end
