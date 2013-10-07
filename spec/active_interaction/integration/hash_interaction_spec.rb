require 'spec_helper'

class HashInteraction < ActiveInteraction::Base
  hash :a do
    hash :x
  end
  hash :b, allow_nil: true do
    boolean :x, default: true
  end
  hash :c, default: {} do
    boolean :x, default: true
  end

  def execute
    { a: a, b: b, c: c }
  end
end

describe HashInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :hash, -> { {} }

  context 'with options[:a]' do
    let(:a) { { 'x' => {} } }

    before { options.merge!(a: a) }

    it 'returns the correct value for :a' do
      expect(result[:a]).to eq a
    end

    it 'returns the correct value for :b' do
      expect(result[:b]).to be_nil
    end

    it 'returns the correct value for :c' do
      expect(result[:c]).to eq(x: true)
    end

    context 'with options[:b]' do
      before { options.merge!(b: { x: false}) }

      it 'returns the correct value for :b' do
        expect(result[:b]).to eq('x' => false)
      end
    end

    context 'with options[:c]' do
      before { options.merge!(c: { x: false }) }

      it 'returns the correct value for :c' do
        expect(result[:c]).to eq('x' => false)
      end
    end
  end

  context 'with an invalid default' do
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          hash :a, default: Object.new
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with an invalid nested default' do
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          hash :a, default: { x: Object.new } do
            hash :x
          end
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end

    # REVIEW: This should probably raise an InvalidDefaultValue error when the
    #   class is initialized.
    it 'raises an error' do
      expect {
        Class.new(ActiveInteraction::Base) do
          def self.name
            SecureRandom.hex
          end

          hash :a do
            hash :x, default: Object.new
          end
        end.run!(a: {})
      }.to raise_error ActiveInteraction::InteractionInvalid
    end
  end
end
