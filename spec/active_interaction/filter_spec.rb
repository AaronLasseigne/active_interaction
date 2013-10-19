require 'spec_helper'

describe ActiveInteraction::Filter do
  describe '.new(type, name, options = {}, &block)' do
    let(:type) { SecureRandom.hex }
    let(:name) { nil }
    let(:options) { {} }
    let(:block) { nil }
    subject(:filter_method) { described_class.new(type, name, options, &block) }

    shared_examples 'instance variable assignment' do
      its(:type) { should equal type }
      its(:name) { should equal name }
      its(:options) { should eq options }
      its(:block) { should equal block }
    end

    include_examples 'instance variable assignment'

    context 'with an name' do
      let(:name) { SecureRandom.hex.to_sym }

      include_examples 'instance variable assignment'
    end

    context 'with options' do
      let(:options) { { nil => nil } }

      include_examples 'instance variable assignment'
    end

    context 'with a block' do
      let(:block) { Proc.new {} }

      include_examples 'instance variable assignment'
    end
  end
end
