# coding: utf-8

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
    CLASSES = {}
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
        CLASSES.fetch(slug) { fail MissingFilterError, slug.inspect }
      end

      private

      # @param slug [Symbol]
      # @param klass [Class]
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
    #   ActiveInteraction::Filter.new(:example).clean(nil)
    #   # => ActiveInteraction::MissingValueError: example
    # @example
    #   ActiveInteraction::Filter.new(:example).clean(0)
    #   # => ActiveInteraction::InvalidValueError: example: 0
    # @example
    #   ActiveInteraction::Filter.new(:example, default: nil).clean(nil)
    #   # => nil
    # @example
    #   ActiveInteraction::Filter.new(:example, default: 0).clean(nil)
    #   # => ActiveInteraction::InvalidDefaultError: example: 0
    #
    # @param value [Object]
    #
    # @return [Object]
    #
    # @raise (see #cast)
    # @raise (see #default)
    def clean(value)
      value = cast(value)
      if value.nil?
        default
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
    # @return (see #raw_default)
    #
    # @raise [NoDefaultError] If the default is missing.
    # @raise [InvalidDefaultError] If the default is invalid.
    def default
      fail NoDefaultError, name unless default?

      value = raw_default
      fail InvalidValueError if value.is_a?(GroupedInput)

      cast(value)
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
    #
    # @return [Object]
    #
    # @raise [MissingValueError] If the value is missing and there is no
    #   default.
    # @raise [InvalidValueError] If the value is invalid.
    #
    # @private
    def cast(value)
      case value
      when NilClass
        fail MissingValueError, name unless default?

        nil
      else
        fail InvalidValueError, "#{name}: #{value.inspect}"
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
    #
    # @since 1.2.0
    def database_column_type
      :string
    end

    private

    # @return [Object]
    def raw_default
      value = options.fetch(:default)

      if value.is_a?(Proc)
        value.call
      else
        value
      end
    end
  end
end
