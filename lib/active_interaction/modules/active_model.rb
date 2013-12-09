# coding: utf-8

module ActiveInteraction
  # @private
  module ActiveModel
    extend ::ActiveSupport::Concern

    include ::ActiveModel::Conversion
    include ::ActiveModel::Validations

    extend ::ActiveModel::Naming

    def i18n_scope
      self.class.i18n_scope
    end

    def new_record?
      true
    end

    def persisted?
      false
    end

    # @private
    module ClassMethods
      def i18n_scope
        :active_interaction
      end
    end
  end
end
