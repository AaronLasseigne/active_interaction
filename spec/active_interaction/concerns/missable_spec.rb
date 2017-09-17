require 'spec_helper'

describe ActiveInteraction::Missable do
  include_context 'concerns', ActiveInteraction::Missable

  describe '#respond_to?(slug, include_all = false)' do
    context 'with invalid slug' do
      let(:slug) { :slug }

      it 'returns false' do
        expect(instance.respond_to?(slug)).to be_falsey
      end
    end

    context 'with valid slug' do
      let(:slug) { :boolean }

      it 'returns true' do
        expect(instance.respond_to?(slug)).to be_truthy
      end
    end
  end

  describe '#method(sym)' do
    context 'with invalid slug' do
      let(:slug) { :slug }

      it 'returns false' do
        expect { instance.method(slug) }.to raise_error NameError
      end
    end

    context 'with valid slug' do
      let(:slug) { :boolean }

      it 'returns true' do
        expect(instance.method(slug)).to be_a Method
      end
    end
  end

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
        expect(instance.method_missing(slug)).to eql instance
      end

      it 'yields' do
        expect do |b|
          instance.method_missing(slug, &b)
        end.to yield_with_args(filter, [], {})
      end

      context 'with names' do
        let(:names) { %i[a b c] }

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
        let(:names) { %i[a b c] }
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
