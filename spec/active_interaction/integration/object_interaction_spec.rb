require 'spec_helper'

ObjectInteraction = Class.new(TestInteraction) do
  object :object
end

describe ObjectInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :object, -> { // }, class: Regexp

  it 'succeeds when given nil' do
    expect { result }.to_not raise_error
  end
end
