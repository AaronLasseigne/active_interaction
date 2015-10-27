# coding: utf-8

require 'active_interaction'

# Update a thing.
class UpdateThing < ActiveInteraction::Base
  object :thing

  string :name,
    default: nil

  validates :name,
    presence: true,
    if: :name?

  # Make this interaction work as a form object.
  def to_model
    thing
  end

  def execute
    thing.name = name if name?
    errors.merge!(thing) unless thing.save
    thing
  end
end
