# frozen_string_literal: true

require 'zeitwerk'
require 'dry/monads'
require 'dry-struct'
require 'dry-types'
require 'linkeddata'
require 'byebug'
require 'csv'
require 'active_support/core_ext/object/blank'

loader = Zeitwerk::Loader.new
loader.push_dir(File.absolute_path("#{__FILE__}/.."))
loader.setup

# Profiles for RDF data.
module Profiles
end
