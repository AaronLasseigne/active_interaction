module ActiveInteraction
  module Attr
    def return_nil(allow_nil)
      allow_nil ? nil : bad_value
    end
    private :return_nil

    def bad_value
      raise ArgumentError
    end
    private :bad_value
  end
end
