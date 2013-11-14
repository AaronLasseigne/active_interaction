require 'active_support/inflector'

module ActiveInteraction
  # @!macro [new] filter_method_params
  #   @param *attributes [Array<Symbol>] attributes to create
  #   @param options [Hash{Symbol => Object}]
  #
  #   @option options [Object] :default fallback value if `nil` is given

  # Describes an input filter for an interaction.
  #
  # @since 0.6.0
  class Filter
    # @return [Regexp]
    CLASS_REGEXP = /\AActiveInteraction::([A-Z]\w*)Filter\z/
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

    # Filters that allow sub-filters, like arrays and hashes, must be able to
    #   use `hash` as a part of their DSL. To keep things consistent, `hash` is
    #   undefined on all filters. Realistically, {#name} should be unique
    #   enough to use in place of {#hash}.
    undef_method :hash

    class << self
      # Get the filter associated with a symbol.
      #
      # @example
      #   ActiveInteraction::Filter.factory(:boolean)
      #   # => ActiveInteraction::BooleanFilter
      #
      # @example
      #   ActiveInteraction::Filter.factory(:invalid)
      #   # => ActiveInteraction::MissingFilterError: :invalid
      #
      # @param slug [Symbol]
      #
      # @return [Class]
      #
      # @raise [MissingFilterError] if the slug doesn't map to a filter
      #
      # @see .slug
      def factory(slug)
        CLASSES.fetch(slug)
      rescue KeyError
        raise MissingFilterError, slug.inspect
      end

      # Convert the class name into a short symbol.
      #
      # @example
      #   ActiveInteraction::BooleanFilter.slug
      #   # => :boolean
      #
      # @example
      #   ActiveInteraction::Filter.slug
      #   # => ActiveInteraction::InvalidClassError: ActiveInteraction::Filter
      #
      # @return [Symbol]
      #
      # @raise [InvalidClassError] if the filter doesn't have a valid slug
      #
      # @see .factory
      def slug
        match = CLASS_REGEXP.match(name)
        raise InvalidClassError, name unless match
        match.captures.first.underscore.to_sym
      end

      # @param klass [Class]
      #
      # @return [nil]
      #
      # @private
      def inherited(klass)
        begin
          CLASSES[klass.slug] = klass
        rescue InvalidClassError
        end

        super
      end
    end

    # @param name [Symbol]
    # @param options [Hash{Symbol => Object}]
    #
    # @option options [Object] :default fallback value to use if `nil` is given
    def initialize(name, options = {}, &block)
      @name = name
      @options = options.dup
      @filters = Filters.new

      instance_eval(&block) if block_given?
    end

    # Convert a value into the expected type. If no value is given, fall back
    #   to the default value.
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).clean(nil)
    #   # => ActiveInteraction::MissingValueError: example
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).clean(0)
    #   # => ActiveInteraction::InvalidValueError: example: 0
    #
    # @example
    #   ActiveInteraction::Filter.new(:example, default: nil).clean(nil)
    #   # => nil
    #
    # @example
    #   ActiveInteraction::Filter.new(:example, default: 0).clean(nil)
    #   # => ActiveInteraction::InvalidDefault: example: 0
    #
    # @param value [Object]
    #
    # @return [Object]
    #
    # @raise (see #cast)
    # @raise (see #default)
    #
    # @see #default
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
    #   ActiveInteraction::Filter.new(:example, default: nil).default
    #   # => nil
    #
    # @example
    #   ActiveInteraction::Filter.new(:example, default: 0).default
    #   # => ActiveInteraction::InvalidDefaultError: example: 0
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).default
    #   # => ActiveInteraction::NoDefaultError: example
    #
    # @return [Object]
    #
    # @raise [InvalidDefaultError] if the default value is invalid
    # @raise [NoDefaultError] if there is no default value
    def default
      raise NoDefaultError, name unless has_default?

      cast(options[:default])
    rescue InvalidValueError, MissingValueError
      raise InvalidDefaultError, "#{name}: #{options[:default].inspect}"
    end

    # Tells if this filter has a default value.
    #
    # @example
    #   filter = ActiveInteraction::Filter.new(:example)
    #   filter.has_default?
    #   # => false
    #
    # @example
    #   filter = ActiveInteraction::Filter.new(:example, default: nil)
    #   filter.has_default?
    #   # => true
    #
    # @return [Boolean]
    def has_default?
      options.has_key?(:default)
    end

    # @param value [Object]
    #
    # @return [nil]
    #
    # @raise [InvalidValueError] if the value is invalid
    # @raise [MissingValueError] if the value is missing and the input is required
    #
    # @private
    def cast(value)
      case value
      when NilClass
        raise MissingValueError, name unless has_default?

        nil
      else
        raise InvalidValueError, "#{name}: #{value.inspect}"
      end
    end
  end
end
