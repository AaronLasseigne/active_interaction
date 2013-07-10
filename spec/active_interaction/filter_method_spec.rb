require 'spec_helper'

describe ActiveInteraction::FilterMethod do
  describe '.new(method_name, *args, &block)' do
    context 'with an attribute name in the args' do
      subject(:filter_method) do
        described_class.new(:method_name, :attribute, {options: true}) do
          'Block'
        end
      end

      its(:method_name) { should eql :method_name }
      its(:attribute)   { should eql :attribute }
      its(:options)     { should eql({options: true}) }
      its(:block)       { should be_a Proc }
    end

    context 'without an attribute name in the args' do
      subject(:filter_method) do
        described_class.new(:method_name, {options: true}) do
          'Block'
        end
      end

      its(:method_name) { should eql :method_name }
      its(:attribute)   { should be_nil }
      its(:options)     { should eql({options: true}) }
      its(:block)       { should be_a Proc }
    end
  end
end
