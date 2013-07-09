require 'spec_helper'

Key = Class.new

shared_examples 'it matches on the class' do |key, options = {}|
  context 'the model class matches the derived key class' do
    it 'passes it on through' do
      model = Key.new

      expect(described_class.prepare(key, model, options)).to equal model
    end
  end

  context 'the model class does not match the derived key class' do
    it 'throws an argument error' do
      expect {
        described_class.prepare(key, double, options)
      }.to raise_error ArgumentError
    end
  end
end

describe ActiveInteraction::ModelAttr do
  describe '#prepare(key, value, options = {})' do
    context 'value is a model' do
      it_behaves_like 'it matches on the class', :key

      context 'the model class does not exist' do
        it 'throws a name error' do
          expect {
            described_class.prepare(:a_constant_that_does_not_exist, double)
          }.to raise_error NameError
        end
      end
    end

    it 'throws an argument error for everything else' do
      expect {
        described_class.prepare(:key, true)
      }.to raise_error ArgumentError
    end

    it_behaves_like 'options includes :allow_nil'

    context 'options' do
      context ':class' do
        context 'is a String' do
          it_behaves_like 'it matches on the class', :a_key_name, class: 'Key'

          context 'the model class does not exist' do
            it 'throws a name error' do
              expect {
                described_class.prepare(:key, double, class: 'NotARealClass')
              }.to raise_error NameError
            end
          end
        end

        context 'is a Constant' do
          it_behaves_like 'it matches on the class', :a_key_name, class: Key
        end
      end
    end
  end
end
