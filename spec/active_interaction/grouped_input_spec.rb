require 'spec_helper'

describe ActiveInteraction::GroupedInput do
  subject(:grouped_input) { described_class.new }

  it 'subclasses OpenStruct' do
    expect(grouped_input).to be_an OpenStruct
  end

  it 'responds to #[]' do
    expect { grouped_input[:key] }.to_not raise_error
  end

  it 'responds to #[]=' do
    expect { grouped_input[:key] = :value }.to_not raise_error
  end
end
