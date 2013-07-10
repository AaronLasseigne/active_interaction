require 'spec_helper'

class ArrayInteraction < IntegrationInteraction
  array :a
  array :b, allow_nil: true
  array :c, allow_nil: true do
    boolean
  end

  def execute
    c || super
  end
end

describe ArrayInteraction do
  include_context 'interactions'
  it_behaves_like 'an integration interaction'

  let(:a) { [false] }
  let(:b) { [true] }
  let(:c) { [false, true] }

  context 'with required option "a"' do
    before { options.merge!(a: a) }

    context 'with optional options "c"' do
      before { options.merge!(c: c) }

      it 'returns the correct value' do
        expect(response).to eq c
      end
    end
  end
end
