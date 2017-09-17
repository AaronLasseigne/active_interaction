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
  class FileFilter < InterfaceFilter
    register :file

    def database_column_type
      self.class.slug
    end

    private

    def methods
      [:rewind]
    end
  end
end
