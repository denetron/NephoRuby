module NephoRuby
  class Address
    attr_accessor :id, :short
    
    def initialize(options = {})
      self.id     = options[:id]
      self.short  = options[:short]
    end
  end
end