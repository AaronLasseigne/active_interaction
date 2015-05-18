# coding: utf-8

# Create some things with some names.
class CreateThings < ActiveRecord::Migration
  def change
    create_table :things do |table|
      table.timestamps null: false
      table.string :name, null: false
    end
  end
end
