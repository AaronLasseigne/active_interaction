# coding: utf-8

require 'spec_helper'
require 'json'
require 'yaml'

describe 'InterfaceInteraction' do
  it_behaves_like 'an interaction',
    :interface,
    -> { [JSON, YAML].sample },
    methods: %i[dump load]
end
