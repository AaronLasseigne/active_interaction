require 'spec_helper'
require 'json'
require 'yaml'

InterfaceInteraction = Class.new(TestInteraction) do
  interface :anything
end

describe InterfaceInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction',
    :interface,
    -> { [JSON, YAML].sample },
    methods: %i[dump load]

  it 'succeeds when given nil' do
    expect { result }.to_not raise_error
  end
end
