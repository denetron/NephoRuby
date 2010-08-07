# The CloudServer object only implements "standard" attributes
# at this point, so we can just inherit from the Server object
# Without having to modify anything
#
# Author::    Daniel Ballenger (mailto:dballenger@denetron.com)
# Copyright:: Copyright (c) 2010 Daniel Ballenger
# License::   MIT

module NephoRuby
  class CloudServer < Server
    def initialize(options = {})
      super
    end
  end
end