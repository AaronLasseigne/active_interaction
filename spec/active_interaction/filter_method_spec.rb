require 'spec_helper'

describe ActiveInteraction::FilterMethod do
  describe '.new(method_name, *args, &block)' do
    let(:method_name) { SecureRandom.hex }
    let(:attribute) { nil }
    let(:options) { {} }
    let(:args) { [] }
    let(:block) { nil }
    subject(:filter_method) { described_class.new(method_name, *args, &block) }

    shared_examples 'instance variable assignment' do
      its(:method_name) { should equal method_name }
      its(:attribute) { should equal attribute }
      its(:options) { should eq options }
      its(:block) { should equal block }
    end

    include_examples 'instance variable assignment'

    context 'with an attribute' do
      let(:attribute) { SecureRandom.hex.to_sym }

      before { args << attribute }

      include_examples 'instance variable assignment'
    end

    context 'with options' do
      let(:options) { { nil => nil } }

      before { args << options }

      include_examples 'instance variable assignment'

      it 'does not allow :default' do
        options.merge!(default: nil)
        expect { filter_method }.to raise_error ArgumentError
      end
    end

    context 'with a block' do
      let(:block) { Proc.new {} }

      include_examples 'instance variable assignment'
    end
  end
end
