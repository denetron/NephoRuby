module NephoRuby
  class Server
    attr_accessor :memory, :power_state, :hostname, :ip_addresses, :created_at, :image
    
    def initialize(options = {})
      self.memory         = options[:memory]
      self.power_state    = options[:power_state]
      self.hostname       = options[:hostname]
      self.ip_addresses   = options[:ip_addresses]
      self.created_at     = options[:created_at] # Time.parse(options[:created_at])
      self.image          = options[:image]
    end
    
    def os
      self.image.name
    end
    
    def arch
      self.image.arch
    end
    
    def to_params
      {}
    end
  end
end