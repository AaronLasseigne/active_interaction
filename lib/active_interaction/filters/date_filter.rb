module ActiveInteraction
  class DateFilter < Filter
    # @param value [Object]
    #
    # @return [Date]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when Date
        value
      when String
        begin
          if options.has_key?(:format)
            Date.strptime(value, options[:format])
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
  end
end
