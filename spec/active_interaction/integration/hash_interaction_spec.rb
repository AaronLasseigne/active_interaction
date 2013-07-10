require 'spec_helper'

class HashInteraction < IntegrationInteraction
  hash :a
  hash :b, allow_nil: true
  hash :c, allow_nil: true do
    boolean :d
  end

  def execute
    c || super
  end
end

describe HashInteraction do
  include_context 'interactions'
  it_behaves_like 'an integration interaction'

  let(:a) { { 'a' => false } }
  let(:b) { { 'b' => true } }
  let(:c) { { 'd' => false } }

  context 'with required option "a"' do
    before { options.merge!(a: a) }

    context 'with optional option "c"' do
      before { options.merge!(c: c) }

      it 'returns the correct value' do
        expect(response).to eq c
      end
    end
  end
end
