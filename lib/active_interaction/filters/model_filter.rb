module ActiveInteraction
  class ModelFilter < Filter
    # @param value [Object]
    #
    # @return [Object]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when klass
        value
      else
        super
      end
    end

    # @return [Class]
    #
    # @raise [Error]
    def klass
      name = @options.fetch(:class, @name).to_s.classify
      name.constantize
    rescue NameError
      # TODO: Better error.
      raise Error.new(name.inspect)
    end
  end
end
