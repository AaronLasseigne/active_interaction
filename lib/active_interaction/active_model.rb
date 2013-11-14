module ActiveInteraction
  # @private
  module ActiveModel
    extend ::ActiveSupport::Concern

    extend ::ActiveModel::Naming
    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    def new_record?
      true
    end

    def persisted?
      false
    end

    def i18n_scope
      self.class.i18n_scope
    end

    # @private
    module ClassMethods
      def i18n_scope
        :active_interaction
      end
    end
  end
end
