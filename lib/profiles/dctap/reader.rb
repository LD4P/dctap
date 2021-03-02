# frozen_string_literal: true

module Profiles
  module Dctap
    # Read DCTAP CSV files into model.
    class Reader
      def self.read(filepath)
        new(filepath).read
      end

      def self.read_all(dirpath)
        filepaths = Dir.glob("#{dirpath}/*.csv").reject do |filepath|
          filepath.include?('all_shapes.csv')
        end
        filepaths.map { |filepath| Reader.read(filepath) }
      end

      def initialize(filepath)
        @filepath = filepath
      end

      def read
        table = CSV.parse(File.read(filepath), headers: true).by_row!
        shape = shape_for(table[0])
        shape[:properties] = table.map { |row| property_for(row) }
        Models::Shape.new(shape)
      end

      private

      attr_reader :filepath

      def shape_for(row)
        {
          id: row['shapeID'],
          label: row['shapeLabel'],
          properties: []
        }.compact
      end

      def property_for(row)
        {
          id: row['propertyID'],
          label: row['propertyLabel'],
          note: row['note'],
          mandatory: row['mandatory']&.downcase == 'true',
          repeatable: row['repeatable']&.downcase == 'true',
          ordered: row['ordered'],
          value_node_types: row['valueNodeType']&.split('|'),
          value_shapes: row['valueShape']&.split('|'),
          value_constraint: row['valueConstraint']
        }.compact
      end
    end
  end
end
