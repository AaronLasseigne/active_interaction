# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
    # @!method self.interface(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #   the attributes implement an interface. An interface can be based on a
    #   set of methods or the existance of a class or module in the ancestors
    #   of the passed value.
    #
    #   @!macro filter_method_params
    #   @option options [Constant, String, Symbol] :from (use the attribute
    #     name) The class or module representing the interface to check for.
    #   @option options [Array<String, Symbol>] :methods ([]) the methods that
    #     objects conforming to this interface should respond to
    #
    #   @example
    #     interface :concern
    #   @example
    #     interface :person,
    #       from: Manageable
    #   @example
    #     interface :serializer,
    #       methods: %i[dump load]
  end

  # @private
  class InterfaceFilter < Filter
    register :interface

    def initialize(name, options = {}, &block)
      if options.key?(:methods) && options.key?(:from)
        raise InvalidFilterError,
          'method and from options cannot both be passed'
      end

      super
    end

    private

    def from
      const_name = options.fetch(:from, name).to_s.camelize
      Object.const_get(const_name)
    rescue NameError
      raise InvalidNameError,
        "constant #{const_name.inspect} does not exist"
    end

    def matches?(value)
      return false if value == nil # rubocop:disable Style/NilComparison
      return matches_methods?(value) if options.key?(:methods)

      const = from
      if checking_class_inheritance?(value, const)
        class_inherits_from?(value, const)
      else
        singleton_ancestor?(value, const)
      end
    rescue NoMethodError
      false
    end

    def matches_methods?(value)
      options[:methods].all? { |method| value.respond_to?(method) }
    end

    def checking_class_inheritance?(value, from)
      value.is_a?(Class) && from.is_a?(Class)
    end

    def class_inherits_from?(klass, inherits_from)
      klass != inherits_from && klass.ancestors.include?(inherits_from)
    end

    def singleton_ancestor?(value, from)
      value.class != from && value.singleton_class.ancestors.include?(from)
    end
  end
end
