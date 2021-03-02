# frozen_string_literal: true

module Profiles
  module Dctap
    module Models
      # Model for a Property.
      class Property < Struct
        attribute :id, Types::String
        attribute? :label, Types::String
        attribute? :note, Types::String
        attribute :mandatory, Types::Bool.default(false)
        attribute :repeatable, Types::Bool.default(false)
        attribute? :ordered, Types::String.enum('LIST', 'SEQ')
        attribute :value_node_types, Types::Array.of(Types::String.enum('IRI', 'LITERAL', 'BNODE'))
        attribute? :value_shapes, Types::Array.of(Types::String)
        attribute? :value_constraint, Types::String
      end
    end
  end
end
