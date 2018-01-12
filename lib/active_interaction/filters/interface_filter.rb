# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.interface(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #   the attributes implement an interface. An interface can be based on a
    #   set of methods or the existance of a class or module in the ancestors
    #   of the passed value.
    #
    #   @!macro filter_method_params
    #   @option options [Constant, String, Symbol] :from (use the attribute
    #     name) The class or module representing the interface to check for.
    #   @option options [Array<String,Symbol>] :methods ([]) the methods that
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

    # rubocop:disable Style/GuardClause
    def initialize(name, options = {}, &block)
      super

      if options.key?(:from) && options.key?(:methods)
        raise InvalidFilterError, ErrorMessage.new(
          issue: {
            desc: 'You cannot pass the from and methods options together.',
            code: source_str,
            lines: [0]
          }
        )
      end
    end
    # rubocop:enable Style/GuardClause

    private

    def from
      const_name = options.fetch(:from, name).to_s.camelize
      Object.const_get(const_name)
    rescue NameError => e
      raise InvalidNameError, ErrorMessage.new(
        issue: {
          desc: e.message,
          code: source_str,
          lines: [0]
        }
      )
    end

    def matches?(object)
      return matches_methods?(object) if options.key?(:methods)

      const = from
      if checking_class_inheritance?(object, const)
        class_inherits_from?(object, const)
      else
        singleton_ancestor?(object, const)
      end
    rescue NoMethodError
      false
    end

    def matches_methods?(object)
      options.fetch(:methods, []).all? { |method| object.respond_to?(method) }
    end

    def checking_class_inheritance?(object, from)
      object.is_a?(Class) && from.is_a?(Class)
    end

    def class_inherits_from?(klass, inherits_from)
      klass != inherits_from && klass.ancestors.include?(inherits_from)
    end

    def singleton_ancestor?(object, from)
      object.class != from && object.singleton_class.ancestors.include?(from)
    end
  end
end
