# frozen_string_literal: true

module Profiles
  module Dctap
    module Models
      # Model for a Value validation report.
      class ValueReport < Struct
        INCORRECT_NODE_TYPE = 'Incorrect node type.'
        VALUE_CONSTRAINT_MISMATCH = 'Value does not satisfy constraint.'

        attribute :value, Types::String
        attribute? :shape_report, ShapeReport
        attribute :errors, Types::Array.of(Types::String.enum(INCORRECT_NODE_TYPE,
                                                              VALUE_CONSTRAINT_MISMATCH))

        def valid?
          errors.empty? && shape_report&.valid? != false
        end
      end
    end
  end
end
