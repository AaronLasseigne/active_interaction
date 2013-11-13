require 'active_support/inflector'

module ActiveInteraction
  # @since 0.6.0
  class Filter
    # @return [Regexp]
    CLASS_REGEXP = /\AActiveInteraction::([A-Z]\w*)Filter\z/.freeze
    private_constant :CLASS_REGEXP

    # @return [Hash{Symbol => Class}]
    CLASSES = {}
    private_constant :CLASSES

    # @return [Filters]
    attr_reader :filters

    # @return [Symbol]
    attr_reader :name

    # @return [Hash{Symbol => Object}]
    attr_reader :options

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
        raise InvalidClass, name unless match
        match.captures.first.underscore.to_sym
      end

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
      @filters = Filters.new

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
      raise MissingDefault, @name unless has_default?

      cast(options[:default])
    rescue InvalidValue, MissingValue
      raise InvalidDefault, "#{@name}: #{options[:default].inspect}"
    end

    # @return [Boolean]
    def has_default?
      options.has_key?(:default)
    end

    # @return [Boolean]
    #
    # @private
    def cast(value)
      case value
      when NilClass
        raise MissingValue, @name unless has_default?

        nil
      else
        raise InvalidValue, "#{@name}: #{value.inspect}"
      end
    end
  end
end
