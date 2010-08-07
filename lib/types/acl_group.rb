module NephoRuby
  class AclGroup
    attr_accessor :id, :name
    
    def initialize(options = {})
      self.id   = options[:id]
      self.name = options[:name]
    end
  end
end