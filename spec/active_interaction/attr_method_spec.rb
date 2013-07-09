require 'spec_helper'

describe ActiveInteraction::AttrMethod do
  describe '.new(method_name, *args, &block)' do
    context 'with an attribute name in the args' do
      subject(:attr_method) do
        described_class.new(:method_name, :attribute, {options: true}) do
          'Block'
        end
      end

      its(:method_name) { should eq :method_name }
      its(:attribute)   { should eq :attribute }
      its(:options)     { should eq({options: true}) }
      its(:block)       { should be_a Proc }
    end

    context 'without an attribute name in the args' do
      subject(:attr_method) do
        described_class.new(:method_name, {options: true}) do
          'Block'
        end
      end

      its(:method_name) { should eq :method_name }
      its(:attribute)   { should be_nil }
      its(:options)     { should eq({options: true}) }
      its(:block)       { should be_a Proc }
    end
  end
end
