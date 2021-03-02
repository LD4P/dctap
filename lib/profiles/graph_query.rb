# frozen_string_literal: true

module Profiles
  # Queries graph using graph patterns.
  class GraphQuery
    def initialize(graph)
      @graph = graph
    end

    def query_first_object(subject, predicate)
      query_all_objects(subject, predicate).first
    end

    def query_all_objects(subject, predicate)
      solutions = RDF::Query.new(RDF::Query::Pattern.new(subject, predicate, :var)).execute(graph)
      solutions.map { |solution| solution[:var] }
    end

    def query_first_object_value(subject, predicate)
      query_all_object_values(subject, predicate).first
    end

    def query_all_object_values(subject, predicate)
      query_all_objects(subject, predicate).map(&:value)
    end

    def query_all_predicates_objects(subject)
      solutions = RDF::Query.new(RDF::Query::Pattern.new(subject, :var1, :var2)).execute(graph)
      solutions.map { |solution| [solution[:var1], solution[:var2]] }
    end

    def match?(subject, predicate, object = nil)
      solutions = RDF::Query.new(RDF::Query::Pattern.new(subject, predicate, object)).execute(graph)
      solutions.length.positive?
    end

    def query_list_object_values(subject)
      return [] if subject.nil?

      objects = [query_first_object(subject, RDF::RDFV.first)]
      next_subject = query_first_object(subject, RDF::RDFV.rest)
      objects.concat(query_list_object_values(next_subject)) unless next_subject == RDF::RDFV.nil || next_subject.nil?
      objects.compact
    end

    private

    attr_reader :graph
  end
end
