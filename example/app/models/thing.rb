# coding: utf-8

# Define a thing with a name.
class Thing < ActiveRecord::Base
  validates :name,
    presence: true
end
