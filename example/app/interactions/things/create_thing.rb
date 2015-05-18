# coding: utf-8

require 'active_interaction'

# Create a new thing.
class CreateThing < ActiveInteraction::Base
  string :name

  validates :name,
    presence: true

  # Make this interaction work as a form object.
  def to_model
    ::Thing.new
  end

  def execute
    thing = Thing.new(inputs)
    errors.merge!(thing) unless thing.save
    thing
  end
end
