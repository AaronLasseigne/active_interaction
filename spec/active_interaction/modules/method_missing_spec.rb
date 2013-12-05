require 'spec_helper'

describe ActiveInteraction::MethodMissing do
  let(:klass) { Class.new { include ActiveInteraction::MethodMissing } }
  subject(:instance) { klass.new }

  describe '#method_missing' do
    context 'with invalid slug' do
      let(:slug) { :slug }

      it 'calls super' do
        expect do
          instance.method_missing(slug)
        end.to raise_error NameError
      end
    end

    context 'with valid slug' do
      let(:filter) { ActiveInteraction::Filter.factory(slug) }
      let(:slug) { :boolean }

      it 'returns self' do
        expect(instance.method_missing(slug)).to eq instance
      end

      it 'yields' do
        expect do |b|
          instance.method_missing(slug, &b)
        end.to yield_with_args(filter, [], {})
      end

      context 'with names' do
        let(:names) { [:a, :b, :c] }

        it 'yields' do
          expect do |b|
            instance.method_missing(:boolean, *names, &b)
          end.to yield_with_args(filter, names, {})
        end
      end

      context 'with options' do
        let(:options) { { a: nil, b: false, c: true } }

        it 'yields' do
          expect do |b|
            instance.method_missing(:boolean, options, &b)
          end.to yield_with_args(filter, [], options)
        end
      end

      context 'with names & options' do
        let(:names) { [:a, :b, :c] }
        let(:options) { { a: nil, b: false, c: true } }

        it 'yields' do
          expect do |b|
            instance.method_missing(:boolean, *names, options, &b)
          end.to yield_with_args(filter, names, options)
        end
      end
    end
  end
end
