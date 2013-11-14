module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Dates. String values are processed using `parse`
    #   unless the format option is given, in which case they will be processed
    #   with `strptime`.
    #
    # @macro filter_method_params
    # @option options [String] :format parse strings using this format string
    #
    # @example
    #   date :birthday
    #
    # @example
    #   date :birthday, format: '%Y-%m-%d'
    #
    # @since 0.1.0
    #
    # @method self.date(*attributes, options = {})
  end

  # @private
  class DateFilter < Filter
    def cast(value)
      case value
      when Date
        value
      when String
        begin
          if has_format?
            Date.strptime(value, format)
          else
            Date.parse(value)
          end
        rescue ArgumentError
          super
        end
      else
        super
      end
    end

    private

    def has_format?
      options.has_key?(:format)
    end

    def format
      options.fetch(:format)
    end
  end
end
