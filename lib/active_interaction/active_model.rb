module ActiveInteraction
  # @private
  module ActiveModel
    extend ::ActiveSupport::Concern

    extend ::ActiveModel::Naming
    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    # @private
    def new_record?
      true
    end

    # @private
    def persisted?
      false
    end

    # @private
    def i18n_scope
      self.class.i18n_scope
    end

    module ClassMethods
      # @private
      def i18n_scope
        :active_interaction
      end
    end
  end
end
