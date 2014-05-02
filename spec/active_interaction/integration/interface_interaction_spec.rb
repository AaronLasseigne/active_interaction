# coding: utf-8

require 'spec_helper'

describe 'InterfaceInteraction' do
  it_behaves_like 'an interaction',
    :interface,
    -> { [[], {}, (0..0)] },
    methods: [:each]
end
