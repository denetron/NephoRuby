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
    
    def to_params
      {
        :ram          => self.ram,
        :storage      => self.storage,
        :name         => self.name,
        :description  => self.description
      }
    end
  end
end