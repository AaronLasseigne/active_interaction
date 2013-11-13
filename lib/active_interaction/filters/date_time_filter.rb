module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are DateTimes. String values are processed using `parse`
    #   unless the format option is given, in which case they will be processed
    #   with `strptime`.
    #
    # @macro filter_method_params
    # @option options [String] :format parse strings using this format string
    #
    # @example
    #   date :start_date
    #
    # @example
    #   date :start_date, format: '%Y-%m-%dT%H:%M:%S%:z'
    #
    # @method self.date_time(*attributes, options = {})
  end

  # @private
  class DateTimeFilter < Filter
    def cast(value)
      case value
      when DateTime
        value
      when String
        begin
          if has_format?
            DateTime.strptime(value, format)
          else
            DateTime.parse(value)
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
