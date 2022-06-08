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

    # Processes the input through the filter and returns a variety of data
    #   about the input.
    #
    # @example
    #   input = ActiveInteraction::Filter.new(:example, default: nil).process(nil, nil)
    #   input.value
    #   # => nil
    #
    # @param value [Object]
    # @param context [Base, nil]
    #
    # @return [Input, ArrayInput, HashInput]
    #
    # @raise (see #default)
    def process(value, context)
      value, error = cast(value, context)

      Input.new(
        value: value,
        error: error
      )
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
    # @return [Object]
    #
    # @raise [NoDefaultError] If the default is missing.
    # @raise [InvalidDefaultError] If the default is invalid.
    def default(context = nil)
      return @default if defined?(@default)

      raise NoDefaultError, name unless default?

      value = raw_default(context)
      raise InvalidDefaultError, "#{name}: #{value.inspect}" if value.is_a?(GroupedInput)

      @default =
        if value.nil?
          nil
        else
          default = process(value, context)
          case default.error
          when InvalidNestedValueError
            raise InvalidDefaultError, "#{name}: #{value.inspect} (#{default.error})"
          when InvalidValueError, MissingValueError
            raise InvalidDefaultError, "#{name}: #{value.inspect}"
          end
          default.value
        end
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

    # Tells whether or not the filter accepts a group of parameters to form a
    # single input.
    #
    # @example
    #   ActiveInteraction::TimeFilter.new(Time.now).accepts_grouped_inputs?
    #   # => true
    # @example
    #   ActiveInteraction::Filter.new(:example).accepts_grouped_inputs?
    #   # => false
    #
    # @return [Boolean]
    def accepts_grouped_inputs?
      false
    end

    private

    def cast(value, context, convert: true, reconstantize: true)
      if matches?(value)
        [adjust_output(value, context), nil]
      elsif value == nil # rubocop:disable Style/NilComparison - BasicObject does not have `nil?`
        default? ? [default(context), nil] : [value, MissingValueError.new(name)]
      elsif reconstantize
        send(__method__, value, context, convert: convert, reconstantize: false)
      elsif convert
        begin
          send(__method__, convert(value), context, convert: false, reconstantize: reconstantize)
        rescue InvalidValueError => e
          [value, e]
        end
      else
        [value, InvalidValueError.new("#{name}: #{describe(value)}")]
      end
    end

    def matches?(_value)
      false
    end

    def adjust_output(value, _context)
      value
    end

    def convert(value)
      value
    end

    def klass
      @klass ||= Object.const_get(self.class.slug.to_s.camelize, false)
    end

    def describe(value)
      value.inspect
    rescue NoMethodError
      "(Object doesn't support #inspect)"
    end

    def raw_default(context)
      value = options.fetch(:default)
      return value unless value.is_a?(Proc)

      if value.arity == 1
        context.instance_exec(self, &value)
      else
        context.instance_exec(&value)
      end
    end
  end
end
