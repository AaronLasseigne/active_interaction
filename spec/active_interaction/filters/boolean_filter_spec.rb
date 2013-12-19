# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::BooleanFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#cast' do
    context 'falsey' do
      [false, '0', 'false', 'FALSE'].each do |value|
        it "returns false for #{value.inspect}" do
          expect(filter.cast(value)).to be_false
        end
      end
    end

    context 'truthy' do
      [true, '1', 'true', 'TRUE'].each do |value|
        it "returns true for #{value.inspect}" do
          expect(filter.cast(value)).to be_true
        end
      end
    end
  end
end
