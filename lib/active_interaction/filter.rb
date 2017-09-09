# frozen_string_literal: true

require 'active_support/inflector'

module ActiveInteraction
  # @!macro [new] filter_method_params
  #   @param *attributes [Array<Symbol>] Attributes to create.
  #   @param options [Hash{Symbol => Object}]
  #
  #   @option options [Object] :default Fallback value if `nil` is given.
  #   @option options [String] :desc Human-readable description of this input.

  # Describes an input filter for an interaction.
  class Filter
    # @return [Hash{Symbol => Class}]
    CLASSES = {} # rubocop:disable Style/MutableConstant
    private_constant :CLASSES

    # @return [Hash{Symbol => Filter}]
    attr_reader :filters

    # @return [Symbol]
    attr_reader :name

    # @return [Hash{Symbol => Object}]
    attr_reader :options

    undef_method :hash

    class << self
      # @return [Symbol]
      attr_reader :slug

      # Get the filter associated with a symbol.
      #
      # @example
      #   ActiveInteraction::Filter.factory(:boolean)
      #   # => ActiveInteraction::BooleanFilter
      # @example
      #   ActiveInteraction::Filter.factory(:invalid)
      #   # => ActiveInteraction::MissingFilterError: :invalid
      #
      # @param slug [Symbol]
      #
      # @return [Class]
      #
      # @raise [MissingFilterError] If the slug doesn't map to a filter.
      #
      # @see .slug
      def factory(slug)
        CLASSES.fetch(slug) { raise MissingFilterError, slug.inspect }
      end

      private

      # @param slug [Symbol]
      #
      # @return [Class]
      def register(slug)
        CLASSES[@slug = slug] = self
      end
    end

    # @param name [Symbol]
    # @param options [Hash{Symbol => Object}]
    #
    # @option options [Object] :default Fallback value to use when given `nil`.
    def initialize(name, options = {}, &block)
      @name = name
      @options = options.dup
      @filters = {}

      instance_eval(&block) if block_given?
    end

    # Convert a value into the expected type. If no value is given, fall back
    #   to the default value.
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).clean(nil, nil)
    #   # => ActiveInteraction::MissingValueError: example
    # @example
    #   ActiveInteraction::Filter.new(:example).clean(0, nil)
    #   # => ActiveInteraction::InvalidValueError: example: 0
    # @example
    #   ActiveInteraction::Filter.new(:example, default: nil).clean(nil, nil)
    #   # => nil
    # @example
    #   ActiveInteraction::Filter.new(:example, default: 0).clean(nil, nil)
    #   # => ActiveInteraction::InvalidDefaultError: example: 0
    #
    # @param value [Object]
    # @param context [Base, nil]
    #
    # @return [Object]
    #
    # @raise (see #cast)
    # @raise (see #default)
    def clean(value, context)
      value = cast(value, context)
      if value.nil?
        default(context)
      else
        value
      end
    end

    # Get the default value.
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).default
    #   # => ActiveInteraction::NoDefaultError: example
    # @example
    #   ActiveInteraction::Filter.new(:example, default: nil).default
    #   # => nil
    # @example
    #   ActiveInteraction::Filter.new(:example, default: 0).default
    #   # => ActiveInteraction::InvalidDefaultError: example: 0
    #
    # @param context [Base, nil]
    #
    # @return (see #raw_default)
    #
    # @raise [NoDefaultError] If the default is missing.
    # @raise [InvalidDefaultError] If the default is invalid.
    def default(context = nil)
      raise NoDefaultError, name unless default?

      value = raw_default(context)
      raise InvalidValueError if value.is_a?(GroupedInput)

      cast(value, context)
    rescue InvalidNestedValueError => e
      raise InvalidDefaultError, "#{name}: #{value.inspect} (#{e})"
    rescue InvalidValueError, MissingValueError
      raise InvalidDefaultError, "#{name}: #{value.inspect}"
    end

    # Get the description.
    #
    # @example
    #   ActiveInteraction::Filter.new(:example, desc: 'Description!').desc
    #   # => "Description!"
    #
    # @return [String, nil]
    def desc
      options[:desc]
    end

    # Tells if this filter has a default value.
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).default?
    #   # => false
    # @example
    #   ActiveInteraction::Filter.new(:example, default: nil).default?
    #   # => true
    #
    # @return [Boolean]
    def default?
      options.key?(:default)
    end

    # @param value [Object]
    # @param _interaction [Base, nil]
    #
    # @return [Object]
    #
    # @raise [MissingValueError] If the value is missing and there is no
    #   default.
    # @raise [InvalidValueError] If the value is invalid.
    #
    # @private
    def cast(value, _interaction)
      case value
      when NilClass
        raise MissingValueError, name unless default?

        nil
      else
        raise InvalidValueError, "#{name}: #{describe(value)}"
      end
    end

    # Gets the type of database column that would represent the filter data.
    #
    # @example
    #   ActiveInteraction::TimeFilter.new(Time.now).database_column_type
    #   # => :datetime
    # @example
    #   ActiveInteraction::Filter.new(:example).database_column_type
    #   # => :string
    #
    # @return [Symbol] A database column type. If no sensible mapping exists,
    #   returns `:string`.
    def database_column_type
      :string
    end

    private

    # @param value [Object]
    # @return [String]
    def describe(value)
      value.inspect
    rescue NoMethodError
      "(Object doesn't support #inspect)"
    end

    # @param context [Base, nil]
    #
    # @return [Object]
    def raw_default(context)
      value = options.fetch(:default)
      return value unless value.is_a?(Proc)

      case value.arity
      when 1 then context.instance_exec(self, &value)
      else context.instance_exec(&value)
      end
    end
  end
end
