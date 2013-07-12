require 'spec_helper'

shared_examples 'all other args are assigned' do
  its(:method_name) { should eql :method_name }
  its(:options)     { should eql({options: true}) }
  its(:block)       { should be_a Proc }
end

describe ActiveInteraction::FilterMethod do
  describe '.new(method_name, *args, &block)' do
    context 'with an attribute name in the args' do
      subject(:filter_method) do
        described_class.new(:method_name, :attribute, {options: true}) do
          'Block'
        end
      end

      its(:attribute) { should eql :attribute }

      it_behaves_like 'all other args are assigned'
    end

    context 'without an attribute name in the args' do
      subject(:filter_method) do
        described_class.new(:method_name, {options: true}) do
          'Block'
        end
      end

      its(:attribute) { should be_nil }

      it_behaves_like 'all other args are assigned'
    end
  end
end
