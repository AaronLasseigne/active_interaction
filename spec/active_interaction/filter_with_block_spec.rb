require 'spec_helper'

describe ActiveInteraction::FilterWithBlock do
  subject(:filter) { described_class.new(:name) }

  describe '.filters' do
    it 'returns a Filters object' do
      expect(filter.filters).to be_a ActiveInteraction::Filters
    end

    context 'with filters' do
      class ActiveInteraction::TestKlassWithBlockFilter < described_class
        def method_missing(type, *args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}

          args.each do |name|
            filters.add(ActiveInteraction::Filter.factory(type).new(name, options.dup, &block))
          end
        end
        private :method_missing
      end

      it 'returns the list of sub-filters' do
        filter = ActiveInteraction::TestKlassWithBlockFilter.new(:name) { test_klass_with_block :sf }

        expect(filter.filters).to have(1).filter
      end
    end
  end
end
