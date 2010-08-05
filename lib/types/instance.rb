module NephoRuby
  class Instance
    attr_accessor :id, :ram, :storage, :name, :description
    
    def initialize(options = {})
      self.id           = options[:id]
      self.ram          = options[:ram]
      self.storage      = options[:storage]
      self.name         = options[:name]
      self.description  = options[:description]
    end
  end
end