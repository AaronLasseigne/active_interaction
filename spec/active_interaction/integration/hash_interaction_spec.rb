require 'spec_helper'

HashInteraction = Class.new(TestInteraction) do
  hash :a do
    hash :x
  end
  hash :b, default: {} do
    hash :x, default: {}
  end
end

describe HashInteraction do
  include_context 'interactions'
  it_behaves_like 'an interaction', :hash, -> { {} }

  context 'with inputs[:a]' do
    let(:a) { { x: {} } }

    before { inputs[:a] = a }

    it 'returns the correct value for :a' do
      expect(result[:a]).to eql a.with_indifferent_access
    end

    it 'returns the correct value for :b' do
      expect(result[:b]).to eql('x' => {})
    end

    it 'does not raise an error with an invalid nested value' do
      inputs[:a] = { x: false }
      expect { outcome }.to_not raise_error
    end
  end

  context 'with an invalid default' do
    it 'raises an error' do
      expect do
        Class.new(ActiveInteraction::Base) do
          hash :a, default: Object.new
        end
      end.to raise_error ActiveInteraction::InvalidDefaultError
    end
  end

  context 'with an invalid default as a proc' do
    it 'does not raise an error' do
      expect do
        Class.new(ActiveInteraction::Base) do
          array :a, default: -> { Object.new }
        end
      end.to_not raise_error
    end
  end

  context 'with an invalid nested default' do
    it 'raises an error with a non-empty hash' do
      expect do
        Class.new(ActiveInteraction::Base) do
          hash :a, default: { x: Object.new } do
            hash :x
          end
        end
      end.to raise_error ActiveInteraction::InvalidDefaultError
    end

    it 'raises an error' do
      expect do
        Class.new(ActiveInteraction::Base) do
          hash :a, default: {} do
            hash :x
          end
        end
      end.to raise_error ActiveInteraction::InvalidDefaultError
    end
  end
end
