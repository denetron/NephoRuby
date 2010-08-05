module NephoRuby
  class Server
    attr_accessor :id, :memory, :power_state, :hostname, :ip_addresses, :created_at, :image, :instance_type, :credential
    
    def initialize(options = {})
      self.id             = options[:id]
      self.memory         = options[:memory]
      self.power_state    = options[:power_state]
      self.hostname       = options[:hostname]
      self.ip_addresses   = options[:ip_addresses]
      self.created_at     = options[:created_at] # Time.parse(options[:created_at])
      self.image          = options[:image]
      # The following should have the objects passed in through the hash, not an ID
      self.credential     = options[:credential]
      self.instance_type  = options[:instance_type]
    end
    
    def os
      self.image.name
    end
    
    def arch
      self.image.arch
    end
    
    def to_params
      {
        :id => self.id || nil,
        :hostname => self.hostname,
        :friendly_name => self.hostname,
        :image => self.image.id,
        :ipaddress_public => self.ip_addresses.first,
        :ipaddress_private => self.ip_addresses.last,
        :key_type => 2,
        :key => (self.credential ? self.credential.id : nil),
        :type => (self.instance_type ? self.instance_type.id : nil)
      }
    end
  end
end