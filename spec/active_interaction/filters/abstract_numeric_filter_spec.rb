require 'spec_helper'

describe ActiveInteraction::AbstractNumericFilter, :filter do
  include_context 'filters'

  describe '#cast' do
    let(:value) { nil }

    it 'raises an error' do
      expect { filter.send(:cast, value, nil) }.to raise_error NameError
    end
  end
end
