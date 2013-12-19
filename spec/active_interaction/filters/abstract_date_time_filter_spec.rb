# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::AbstractDateTimeFilter, :filter do
  include_context 'filters'

  describe '#cast' do
    let(:value) { nil }

    it 'raises an error' do
      expect { filter.cast(value) }.to raise_error NotImplementedError
    end
  end
end
