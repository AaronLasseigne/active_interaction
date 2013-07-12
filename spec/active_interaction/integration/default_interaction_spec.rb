require 'spec_helper'

class DefaultInteraction < ActiveInteraction::Base
  array :array, default: []
  array :nil_array, allow_nil: true, default: nil
  array :nested_array, default: [true] do
    boolean
  end

  def execute
    [array, nil_array, nested_array]
  end
end

describe DefaultInteraction do
  include_context 'interactions'

  context 'with a default' do
    it 'uses the default' do
      expect(result[0]).to eq []
    end

    it 'uses the option instead of default' do
      array = [rand]
      options.merge!(array: array)
      expect(result[0]).to eq array
    end
  end

  context 'with a nil default' do
    it 'uses the default' do
      expect(result[1]).to be_nil
    end
  end

  context 'with a default with a constraint' do
    it 'uses the default' do
      expect(result[2]).to eq [true]
    end
  end

  context 'with an invalid default' do
    it 'raises an error' do
      expect {
        class InteractionWithInvalidDefaultArray < ActiveInteraction::Base
          array :a, default: Object.new
          def execute; end
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with an invalid default with a constraint' do
    it 'raises an error' do
      expect {
        class InteractionWithInvalidNestedDefaultArray < ActiveInteraction::Base
          array :a, default: [Object.new] do
            array
          end
          def execute; end
        end
      }.to raise_error ActiveInteraction::InvalidDefaultValue
    end
  end

  context 'with an invalidly nested default' do
    it do
      expect {
        class InteractionWithInvalidlyNestedDefault < ActiveInteraction::Base
          array :a do
            array default: []
          end
          def execute; end
        end
        # TODO: We should fail when defining the class, not when trying to run it.
        InteractionWithInvalidlyNestedDefault.run(a: [])
      }.to raise_error ArgumentError
    end
  end
end
