# coding: utf-8

require 'spec_helper'
require 'json'
require 'yaml'

class InterfaceInteraction < TestInteraction
  interface :anything
end

describe InterfaceInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction',
    :interface,
    -> { [JSON, YAML].sample },
    methods: [:dump, :load]

  it 'succeeds when given nil' do
    expect { result }.to_not raise_error
  end
end
