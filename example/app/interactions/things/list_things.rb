# coding: utf-8

require 'active_interaction'

# List all the things.
class ListThings < ActiveInteraction::Base
  def execute
    Thing.all
  end
end
