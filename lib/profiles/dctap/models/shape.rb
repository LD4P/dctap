# frozen_string_literal: true

module Profiles
  module Dctap
    module Models
      # Model for a Shape.
      class Shape < Struct
        attribute :id, Types::String
        attribute? :label, Types::String
        attribute :properties, Types::Array.of(Property)
      end
    end
  end
end
