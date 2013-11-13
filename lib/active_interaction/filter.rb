require 'active_support/inflector'

module ActiveInteraction
  # Describes an input filter for an interaction.
  #
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
      #   # => ActiveInteraction::MissingFilter: :invalid
      #
      # @param slug [Symbol]
      #
      # @return [Class]
      #
      # @raise [MissingFilter] if the slug doesn't map to a filter
      #
      # @see .slug
      def factory(slug)
        CLASSES.fetch(slug)
      rescue KeyError
        raise MissingFilter, slug.inspect
      end

      # Convert the class name into a short symbol.
      #
      # @example
      #   ActiveInteraction::BooleanFilter.slug
      #   # => :boolean
      #
      # @example
      #   ActiveInteraction::Filter.slug
      #   # => ActiveInteraction::InvalidClass: ActiveInteraction::Filter
      #
      # @return [Symbol]
      #
      # @raise [InvalidClass] if the filter doesn't have a valid slug
      #
      # @see .factory
      def slug
        match = CLASS_REGEXP.match(name)
        raise InvalidClass, name unless match
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
        rescue InvalidClass
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
    #   # => ActiveInteraction::MissingValue: example
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).clean(0)
    #   # => ActiveInteraction::InvalidValue: example: 0
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
    #   # => ActiveInteraction::InvalidDefault: example: 0
    #
    # @example
    #   ActiveInteraction::Filter.new(:example).default
    #   # => ActiveInteraction::MissingDefault: example
    #
    # @return [Object]
    #
    # @raise [InvalidDefault] if the default value is invalid
    # @raise [MissingDefault] if there is no default value
    def default
      raise MissingDefault, @name unless has_default?

      cast(options[:default])
    rescue InvalidValue, MissingValue
      raise InvalidDefault, "#{@name}: #{options[:default].inspect}"
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
    # @raise [InvalidValue] if the value is invalid
    # @raise [MissingValue] if the value is missing and the input is required
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
