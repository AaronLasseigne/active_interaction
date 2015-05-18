# coding: utf-8

require 'active_interaction'

# Find a thing.
class FindThing < ActiveInteraction::Base
  integer :id

  def execute
    thing = Thing.find_by_id(id)
    errors.add(:id, :not_found) unless thing
    thing
  end
end
