# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::GroupedInput do
  subject(:grouped_input) { described_class.new }

  it 'subclasses OpenStruct' do
    expect(grouped_input).to be_an OpenStruct
  end
end
