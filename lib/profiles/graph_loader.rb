# frozen_string_literal: true

module Profiles
  # Helper for loading profiles
  class GraphLoader
    def self.from_uri(uri)
      RDF::Repository.load(uri)
    end

    def self.from_ttl(ttl)
      RDF::Repository.new.from_ttl(ttl)
    end
  end
end
