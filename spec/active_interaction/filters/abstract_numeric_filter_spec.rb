require 'spec_helper'

describe ActiveInteraction::AbstractNumericFilter, :filter do
  include_context 'filters'

  describe '#process' do
    let(:value) { nil }

    it 'raises an error' do
      expect { filter.process(value, nil) }.to raise_error NameError
    end
  end
end
