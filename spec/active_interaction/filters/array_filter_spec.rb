require 'spec_helper'

describe ActiveInteraction::ArrayFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  context 'with multiple nested filters' do
    let(:block) do
      proc do
        array
        array
      end
    end

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  context 'with a nested name' do
    let(:block) { proc { array :a } }

    it 'raises an error' do
      expect { filter }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  describe '#process' do
    let(:result) { filter.process(value, nil) }

    context 'with an Array' do
      let(:value) { [] }

      it 'returns an ArrayInput' do
        expect(result).to be_an_instance_of ActiveInteraction::ArrayInput
      end

      it 'returns the Array' do
        expect(result.value).to eql value
      end

      it 'has no children' do
        expect(result.children).to eql []
      end
    end

    context 'with an implicit Array' do
      let(:value) do
        Class.new do
          def to_ary
            [1, 2, 3]
          end
        end.new
      end

      it 'returns the Array' do
        expect(result.value).to eql value.to_ary
      end
    end

    context 'with a heterogenous Array' do
      let(:value) { [[], false, 0.0, {}, 0, '', :''] }

      it 'returns the Array' do
        expect(result.value).to eql value
      end
    end

    context 'with a nested filter' do
      let(:block) { proc { array } }

      context 'with an Array' do
        let(:child_value) { [] }
        let(:value) { [child_value, child_value] }

        it 'returns the Array' do
          expect(result.value).to eql value
        end

        it 'has children' do
          expect(result.children.size).to be 2
          result.children.each do |child|
            expect(child).to be_an_instance_of ActiveInteraction::ArrayInput
            expect(child.value).to be child_value
          end
        end

        context 'given a nil value' do
          let(:value) { nil }

          it 'returns an error' do
            expect(result.value).to eql value
            expect(result.error).to be_an_instance_of ActiveInteraction::MissingValueError
          end
        end
      end

      context 'with an Array of Arrays' do
        let(:value) { [[]] }

        it 'returns the Array' do
          expect(result.value).to eql value
        end
      end

      context 'with a heterogenous Array' do
        let(:value) { [[], false, 0.0, {}, 0, '', :''] }

        it 'indicates an error' do
          expect(
            result.error
          ).to be_an_instance_of ActiveInteraction::InvalidValueError
        end

        context 'when :index_errors is true' do
          before do
            options[:index_errors] = true
          end

          it 'attaches the index of the value where the error occurred' do
            expect(result.error.index).to be 1
            expect(result.error).to be_index_error
          end
        end

        context 'when ActiveRecord.index_nested_attribute_errors is true' do
          before do
            if ::ActiveRecord.respond_to?(:index_nested_attribute_errors)
              allow(::ActiveRecord).to receive(:index_nested_attribute_errors).and_return(true)
            else
              allow(::ActiveRecord::Base).to receive(:index_nested_attribute_errors).and_return(true)
            end
          end

          it 'attaches the index of the value where the error occurred' do
            expect(result.error.index).to be 1
            expect(result.error).to be_index_error
          end

          context 'when :index_errors is false' do
            before do
              options[:index_errors] = false
            end

            it 'does not attach the index' do
              expect(result.error.index).to be 1
              expect(result.error).to_not be_index_error
            end
          end
        end
      end
    end

    [
      %i[object class],
      %i[record class],
      %i[interface from]
    ].each do |(type, option)|
      context "with a nested #{type} filter" do
        let(:block) { proc { public_send(type) } }
        let(:name) { :objects }
        let(:value) { [''] }

        it 'does not raise an error' do
          expect { result }.to_not raise_error
        end

        it 'has a filter with the right key' do
          expect(filter.filters).to have_key(:'0')
        end

        it 'has a filter with the right option' do
          expect(filter.filters[:'0'].options).to have_key(option)
        end

        context 'with a class set' do
          let(:block) { proc { public_send(type, "#{option}": String) } }

          it "does not override the #{option}" do
            expect(filter.filters[:'0'].options[option]).to eql String
          end
        end
      end
    end

    context 'with a nested interface type' do
      context 'with the methods option set' do
        let(:block) { proc { public_send(:interface, methods: %i[to_s]) } }

        it 'has a filter with the right option' do
          expect(filter.filters[:'0'].options).to have_key(:methods)
          expect(filter.filters[:'0'].options[:methods]).to eql %i[to_s]
        end
      end

      context 'with another option set' do
        let(:block) { proc { public_send(:object, converter: :new) } }
        let(:name) { :objects }

        it 'has a filter with the right options' do
          expect(filter.filters[:'0'].options).to have_key(:class)
          expect(filter.filters[:'0'].options[:class]).to be :Object
          expect(filter.filters[:'0'].options).to have_key(:converter)
          expect(filter.filters[:'0'].options[:converter]).to be :new
        end
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to be :string
    end
  end
end
