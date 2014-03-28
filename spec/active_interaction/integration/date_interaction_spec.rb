# coding: utf-8

require 'spec_helper'

describe 'DateInteraction' do
  it_behaves_like 'an interaction', :date, -> { Date.today }

  context 'with rails form parameters' do
    it 'parses the options' do
      interaction = Class.new(ActiveInteraction::Base) do
        date :a

        def self.name
          SecureRandom.hex
        end

        def execute
          a
        end
      end

      inputs  = {"a(1i)" => '2011', 'a(2i)' => '12', 'a(3i)' => '13'}
      outcome = interaction.run(inputs)
      result  = outcome.result
      expect(outcome).to be_valid
      expect(result).to eq Date.new(2011, 12, 13)
    end
  end
end
