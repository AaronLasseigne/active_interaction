# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.file(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #   the attributes respond to the `rewind` method. This is useful when
    #   passing in Rails params that include a file upload or another generic
    #   IO object.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     file :image
  end

  # @private
  class FileFilter < Filter
    register :file

    def database_column_type
      self.class.slug
    end

    private

    def matches?(object)
      object.respond_to?(:rewind)
    rescue NoMethodError
      false
    end
  end
end
