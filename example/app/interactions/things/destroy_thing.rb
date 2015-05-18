# coding: utf-8

require 'active_interaction'

# Destroy a thing.
class DestroyThing < ActiveInteraction::Base
  object :thing

  def execute
    thing.destroy
  end
end
