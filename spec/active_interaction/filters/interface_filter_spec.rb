require 'spec_helper'

module InterfaceModule; end
class InterfaceClass; end

describe ActiveInteraction::InterfaceFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter' do
    let(:name) { :interface_module }
  end

  describe '#cast' do
    let(:result) { filter.cast(value, nil) }

    context 'with an implicit constant name' do
      context 'passed an instance' do
        context 'with the module included' do
          let(:name) { :interface_module }
          let(:value) do
            Class.new do
              include InterfaceModule
            end.new
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'with the class inherited from' do
          let(:name) { :interface_class }
          let(:value) do
            Class.new(InterfaceClass) {}.new
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that is extended by the ancestor' do
          let(:name) { :interface_module }
          let(:value) do
            Class.new {}.new.extend(InterfaceModule)
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that does not match' do
          let(:name) { :interface_module }
          let(:value) { Class.new }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with the class itself' do
          let(:name) { :interface_class }
          let(:value) do
            InterfaceClass.new
          end

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end
      end

      context 'passed a class' do
        context 'with the class inherited from' do
          let(:name) { :interface_class }
          let(:value) do
            Class.new(InterfaceClass) {}
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that is extended by the ancestor' do
          let(:name) { :interface_module }
          let(:value) do
            Class.new do
              extend InterfaceModule
            end
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that does not match' do
          let(:name) { :interface_class }
          let(:value) { Class }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with the class itself' do
          let(:name) { :interface_class }
          let(:value) { InterfaceClass }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end
      end

      context 'passed a module' do
        context 'that is extended by the ancestor' do
          let(:name) { :interface_module }
          let(:value) do
            Module.new do
              extend InterfaceModule
            end
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that does not match' do
          let(:name) { :interface_module }
          let(:value) { Module.new }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with the module itself' do
          let(:name) { :interface_module }
          let(:value) { InterfaceModule }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end
      end

      context 'given an invalid name' do
        let(:name) { :invalid }
        let(:value) { Object }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidNameError
        end
      end
    end

    context 'with a constant given' do
      context 'passed an instance' do
        context 'with the module included' do
          before { options.merge!(from: :interface_module) }
          let(:value) do
            Class.new do
              include InterfaceModule
            end.new
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'with the class inherited from' do
          before { options.merge!(from: :interface_class) }
          let(:value) do
            Class.new(InterfaceClass) {}.new
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that is extended by the ancestor' do
          before { options.merge!(from: :interface_module) }
          let(:value) do
            Class.new {}.new.extend(InterfaceModule)
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that does not match' do
          let(:name) { :interface_class }
          let(:value) { Class.new }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with the class itself' do
          let(:name) { :interface_class }
          let(:value) { InterfaceClass.new }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end
      end

      context 'passed a class' do
        context 'with the class inherited from' do
          before { options.merge!(from: :interface_class) }
          let(:value) do
            Class.new(InterfaceClass) {}
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that is extended by the ancestor' do
          before { options.merge!(from: :interface_module) }
          let(:value) do
            Class.new do
              extend InterfaceModule
            end
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that does not match' do
          let(:name) { :interface_class }
          let(:value) { Class }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with the class itself' do
          let(:name) { :interface_class }
          let(:value) { InterfaceClass }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end
      end

      context 'passed a module' do
        context 'that is extended by the ancestor' do
          before { options.merge!(from: :interface_module) }
          let(:value) do
            Module.new do
              extend InterfaceModule
            end
          end

          it 'returns a the value' do
            expect(result).to eql value
          end
        end

        context 'that does not match' do
          let(:name) { :interface_module }
          let(:value) { Module.new }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end

        context 'with the module itself' do
          let(:name) { :interface_module }
          let(:value) { InterfaceModule }

          it 'raises an error' do
            expect do
              result
            end.to raise_error ActiveInteraction::InvalidValueError
          end
        end
      end

      context 'given an invalid name' do
        before { options.merge!(from: :invalid) }
        let(:value) { Object }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidNameError
        end
      end
    end

    context 'with methods passed' do
      before { options[:methods] = %i[dump load] }

      context 'passed an valid instance' do
        let(:value) do
          Class.new do
            def dump; end

            def load; end
          end.new
        end

        it 'returns a the value' do
          expect(result).to eql value
        end
      end

      context 'passed an invalid instance' do
        let(:value) { Class.new }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end

      context 'passed a class' do
        let(:value) do
          Class.new do
            def self.dump; end

            def self.load; end
          end
        end

        it 'returns a the value' do
          expect(result).to eql value
        end
      end

      context 'passed an invalid class' do
        let(:value) { Class }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end

      context 'passed a module' do
        let(:value) do
          Module.new do
            def self.dump; end

            def self.load; end
          end
        end

        it 'returns a the value' do
          expect(result).to eql value
        end
      end

      context 'passed an invalid module' do
        let(:value) { Module.new }

        it 'raises an error' do
          expect do
            result
          end.to raise_error ActiveInteraction::InvalidValueError
        end
      end
    end

    context 'with from and methods passed' do
      before do
        options[:from] = :module
        options[:methods] = %i[dump load]
      end

      it 'raises an error' do
        expect do
          filter
        end.to raise_error ActiveInteraction::InvalidFilterError
      end
    end
  end

  describe '#database_column_type' do
    it 'returns :string' do
      expect(filter.database_column_type).to eql :string
    end
  end
end
