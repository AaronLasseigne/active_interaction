require 'active_support/inflector'

module ActiveInteraction
  class Filter
    # @return [Regexp]
    CLASS_REGEXP = /\AActiveInteraction::([A-Z]\w*)Filter\z/.freeze

    # @return [Hash{Symbol => Class}]
    CLASSES = {}

    # @return [Array<Filter>]
    attr_reader :filters

    # @return [Symbol]
    attr_reader :name

    undef_method :hash

    class << self
      # @param slug [Symbol]
      #
      # @return [Filter]
      #
      # @raise [MissingFilter]
      def factory(slug)
        CLASSES.fetch(slug)
      rescue KeyError
        raise MissingFilter.new(slug.inspect)
      end

      # @param klass [Filter]
      def inherited(klass)
        CLASSES[klass.slug] = klass
        super
      end

      # @return [Symbol]
      #
      # @raise [InvalidFilter]
      def slug
        match = CLASS_REGEXP.match(name)
        raise InvalidFilter.new(name.inspect) unless match
        match.captures.first.underscore.to_sym
      end
    end

    # @param name [Symbol]
    # @param options [Hash{Symbol => Object}]
    #
    # @option options [Object] :default
    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      @filters = []

      instance_eval(&block) if block_given?
    end

    # @param value [Object]
    #
    # @return [Object]
    #
    # @raise [InvalidValue]
    # @raise [MissingValue]
    def cast(value)
      case value
      when NilClass
        raise MissingValue.new(@name) if required?

        nil
      else
        raise InvalidValue.new("#{@name}: #{value.inspect}")
      end
    end

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

    # @return [Object]
    #
    # @raise [InvalidDefault]
    # @raise [MissingDefault]
    def default
      raise MissingDefault.new(@name) if required?

      cast(@options[:default])
    rescue InvalidValue, MissingValue
      raise InvalidDefault.new("#{@name}: #{@options[:default].inspect}")
    end

    # @return [Boolean]
    def optional?
      @options.has_key?(:default)
    end

    # @return [Boolean]
    #
    # @see #optional?
    def required?
      !optional?
    end
  end
end
