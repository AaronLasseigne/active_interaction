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

  it 'uses the default' do
    expect(result[0]).to eq []
  end

  it 'uses the option instead of default' do
    array = [rand]
    options.merge!(array: array)
    expect(result[0]).to eq array
  end

  it 'uses nil as the default' do
    expect(result[1]).to be_nil
  end

  it 'uses the default' do
    expect(result[2]).to eq [true]
  end

  it do
    expect {
      class InteractionWithInvalidDefaultArray < ActiveInteraction::Base
        array :a, default: Object.new
        def execute; end
      end
    }.to raise_error ActiveInteraction::InvalidDefaultValue
  end

  it do
    expect {
      class InteractionWithInvalidNestedDefaultArray < ActiveInteraction::Base
        array :a, default: [Object.new] do
          array
        end
        def execute; end
      end
    }.to raise_error ActiveInteraction::InvalidDefaultValue
  end

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
