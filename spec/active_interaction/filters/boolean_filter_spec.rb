require 'spec_helper'

describe ActiveInteraction::BooleanFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  describe '#process' do
    context 'falsey' do
      [false, '0', 'false', 'FALSE', 'off', 'OFF'].each do |value|
        it "returns false for #{value.inspect}" do
          expect(filter.process(value, nil).value).to be_falsey
        end
      end

      context 'with an implicit string' do
        let(:value) do
          Class.new do
            def to_str
              'false'
            end
          end.new
        end

        it 'returns false' do
          expect(filter.process(value, nil).value).to be_falsey
        end
      end
    end

    context 'truthy' do
      [true, '1', 'true', 'TRUE', 'on', 'ON'].each do |value|
        it "returns true for #{value.inspect}" do
          expect(filter.process(value, nil).value).to be_truthy
        end
      end

      context 'with an implicit string' do
        let(:value) do
          Class.new do
            def to_str
              'true'
            end
          end.new
        end

        it 'returns true' do
          expect(filter.process(value, nil).value).to be_truthy
        end
      end
    end

    context 'with a blank String' do
      let(:value) do
        Class.new do
          def to_str
            ' '
          end
        end.new
      end

      context 'optional' do
        include_context 'optional'

        it 'returns the default' do
          expect(filter.process(value, nil).value).to eql options[:default]
        end
      end

      context 'required' do
        include_context 'required'

        it 'indicates an error' do
          expect(
            filter.process(value, nil).error
          ).to be_an_instance_of ActiveInteraction::MissingValueError
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :boolean' do
      expect(filter.database_column_type).to eql :boolean
    end
  end
end
