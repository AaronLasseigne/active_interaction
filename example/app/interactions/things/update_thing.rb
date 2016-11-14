# coding: utf-8

require 'active_interaction'

# Update a thing.
class UpdateThing < ActiveInteraction::Base
  object :thing

  string :name,
    default: nil

  validates :name,
    presence: true,
    unless: 'name.nil?'

  # Make this interaction work as a form object.
  def to_model
    thing
  end

  def execute
    thing.name = name if name.present?
    errors.merge!(thing.errors) unless thing.save
    thing
  end
end
