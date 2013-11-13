require 'active_support/inflector'

module ActiveInteraction
  class Filter
    # @return [Regexp]
    CLASS_REGEXP = /\AActiveInteraction::([A-Z]\w*)Filter\z/.freeze
    private_constant :CLASS_REGEXP

    # @return [Hash{Symbol => Class}]
    CLASSES = {}
    private_constant :CLASSES

    # @return [Array<Filter>]
    attr_reader :filters

    # @return [Symbol]
    attr_reader :name

    undef_method :hash

    class << self
      # @param slug [Symbol]
      #
      # @return [Class]
      #
      # @raise [MissingFilter]
      def factory(slug)
        CLASSES.fetch(slug)
      rescue KeyError
        raise MissingFilter, slug.inspect
      end

      # @return [Symbol]
      #
      # @raise [InvalidClass]
      def slug
        match = CLASS_REGEXP.match(name)
        raise InvalidClass, name.inspect unless match
        match.captures.first.underscore.to_sym
      end

      private

      # @param klass [Class]
      def inherited(klass)
        begin
          CLASSES[klass.slug] = klass
        rescue InvalidClass
        end

        super
      end
    end

    # @param name [Symbol]
    # @param options [Hash{Symbol => Object}]
    #
    # @option options [Object] :default
    def initialize(name, options = {}, &block)
      @name = name
      @options = options.dup
      @filters = []

      instance_eval(&block) if block_given?
    end

    # @param value [Object]
    #
    # @return [nil]
    #
    # @raise [InvalidValue]
    # @raise [MissingValue]
    def cast(value)
      case value
      when NilClass
        raise MissingValue, @name if required?

        nil
      else
        raise InvalidValue, "#{@name}: #{value.inspect}"
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
      raise MissingDefault, @name if required?

      cast(@options[:default])
    rescue InvalidValue, MissingValue
      raise InvalidDefault, "#{@name}: #{@options[:default].inspect}"
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
